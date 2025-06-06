/*
 * Copyright 2004-2025 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.command;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import org.h2.engine.Constants;
import org.h2.engine.GeneratedKeysMode;
import org.h2.engine.SessionRemote;
import org.h2.engine.SysProperties;
import org.h2.expression.ParameterInterface;
import org.h2.expression.ParameterRemote;
import org.h2.message.DbException;
import org.h2.message.Trace;
import org.h2.result.BatchResult;
import org.h2.result.MergedResult;
import org.h2.result.ResultInterface;
import org.h2.result.ResultRemote;
import org.h2.result.ResultWithGeneratedKeys;
import org.h2.util.Utils;
import org.h2.value.Transfer;
import org.h2.value.Value;
import org.h2.value.ValueLob;
import org.h2.value.ValueNull;

/**
 * Represents the client-side part of a SQL statement.
 * This class is not used in embedded mode.
 */
public class CommandRemote implements CommandInterface {

    private final ArrayList<Transfer> transferList;
    private final ArrayList<ParameterInterface> parameters;
    private final Trace trace;
    private final String sql;
    private SessionRemote session;
    private int id;
    private boolean isQuery;
    private int cmdType = UNKNOWN;
    private boolean readonly;
    private final int created;

    public CommandRemote(SessionRemote session,
            ArrayList<Transfer> transferList, String sql) {
        this.transferList = transferList;
        trace = session.getTrace();
        this.sql = sql;
        parameters = Utils.newSmallArrayList();
        prepare(session, true);
        // set session late because prepare might fail - in this case we don't
        // need to close the object
        this.session = session;
        created = session.getLastReconnect();
    }

    @Override
    public void stop(boolean commitIfAutoCommit) {
        // Ignore
    }

    private void prepare(SessionRemote s, boolean createParams) {
        id = s.getNextId();
        for (int i = 0, count = 0; i < transferList.size(); i++) {
            try {
                Transfer transfer = transferList.get(i);

                if (createParams) {
                    s.traceOperation("SESSION_PREPARE_READ_PARAMS2", id);
                    transfer.writeInt(SessionRemote.SESSION_PREPARE_READ_PARAMS2)
                            .writeInt(id).writeString(sql);
                } else {
                    s.traceOperation("SESSION_PREPARE", id);
                    transfer.writeInt(SessionRemote.SESSION_PREPARE).
                        writeInt(id).writeString(sql);
                }
                s.done(transfer);
                isQuery = transfer.readBoolean();
                readonly = transfer.readBoolean();

                cmdType = createParams ? transfer.readInt() : UNKNOWN;

                int paramCount = transfer.readInt();
                if (createParams) {
                    parameters.clear();
                    for (int j = 0; j < paramCount; j++) {
                        ParameterRemote p = new ParameterRemote(j);
                        p.readMetaData(transfer);
                        parameters.add(p);
                    }
                }
            } catch (IOException e) {
                s.removeServer(e, i--, ++count);
            }
        }
    }

    @Override
    public boolean isQuery() {
        return isQuery;
    }

    @Override
    public ArrayList<ParameterInterface> getParameters() {
        return parameters;
    }

    private void prepareIfRequired() {
        if (session.getLastReconnect() != created) {
            // in this case we need to prepare again in every case
            id = Integer.MIN_VALUE;
        }
        session.checkClosed();
        if (id <= session.getCurrentId() - SysProperties.SERVER_CACHED_OBJECTS) {
            // object is too old - we need to prepare again
            prepare(session, false);
        }
    }

    @Override
    public ResultInterface getMetaData() {
        final SessionRemote session = this.session;
        session.lock();
        try {
            if (!isQuery) {
                return null;
            }
            int objectId = session.getNextId();
            ResultRemote result = null;
            for (int i = 0, count = 0; i < transferList.size(); i++) {
                prepareIfRequired();
                Transfer transfer = transferList.get(i);
                try {
                    session.traceOperation("COMMAND_GET_META_DATA", id);
                    transfer.writeInt(SessionRemote.COMMAND_GET_META_DATA).
                            writeInt(id).writeInt(objectId);
                    session.done(transfer);
                    int columnCount = transfer.readInt();
                    result = new ResultRemote(session, transfer, objectId,
                            columnCount, Integer.MAX_VALUE);
                    break;
                } catch (IOException e) {
                    session.removeServer(e, i--, ++count);
                }
            }
            session.autoCommitIfCluster();
            return result;
        } finally {
            session.unlock();
        }
    }

    @Override
    public ResultInterface executeQuery(long maxRows, int fetchSize, boolean scrollable) {
        checkParameters();
        final SessionRemote session = this.session;
        session.lock();
        try {
            int objectId = session.getNextId();
            ResultRemote result = null;
            for (int i = 0, count = 0; i < transferList.size(); i++) {
                prepareIfRequired();
                Transfer transfer = transferList.get(i);
                try {
                    session.traceOperation("COMMAND_EXECUTE_QUERY", id);
                    transfer.writeInt(SessionRemote.COMMAND_EXECUTE_QUERY).writeInt(id).writeInt(objectId);
                    transfer.writeRowCount(maxRows);
                    int fetch;
                    if (session.isClustered() || scrollable) {
                        fetch = Integer.MAX_VALUE;
                    } else {
                        fetch = fetchSize;
                    }
                    transfer.writeInt(fetch);
                    sendParameters(transfer);
                    session.done(transfer);
                    int columnCount = transfer.readInt();
                    if (result != null) {
                        result.close();
                        result = null;
                    }
                    result = new ResultRemote(session, transfer, objectId, columnCount, fetch);
                    if (readonly) {
                        break;
                    }
                } catch (IOException e) {
                    session.removeServer(e, i--, ++count);
                }
            }
            session.autoCommitIfCluster();
            session.readSessionState();
            return result;
        } finally {
            session.unlock();
        }
    }

    @Override
    public ResultWithGeneratedKeys executeUpdate(Object generatedKeysRequest) {
        checkParameters();
        int generatedKeysMode = GeneratedKeysMode.valueOf(generatedKeysRequest);
        boolean readGeneratedKeys = generatedKeysMode != GeneratedKeysMode.NONE;
        int objectId = readGeneratedKeys ? session.getNextId() : 0;
        final SessionRemote session = this.session;
        session.lock();
        try {
            long updateCount = 0L;
            ResultRemote generatedKeys = null;
            boolean autoCommit = false;
            for (int i = 0, count = 0; i < transferList.size(); i++) {
                prepareIfRequired();
                Transfer transfer = transferList.get(i);
                try {
                    session.traceOperation("COMMAND_EXECUTE_UPDATE", id);
                    transfer.writeInt(SessionRemote.COMMAND_EXECUTE_UPDATE).writeInt(id);
                    sendParameters(transfer);
                    sendGeneratedKeysRequest(generatedKeysRequest, generatedKeysMode, transfer);
                    session.done(transfer);
                    updateCount = transfer.readRowCount();
                    autoCommit = transfer.readBoolean();
                    if (readGeneratedKeys) {
                        int columnCount = transfer.readInt();
                        if (generatedKeys != null) {
                            generatedKeys.close();
                            generatedKeys = null;
                        }
                        generatedKeys = new ResultRemote(session, transfer, objectId, columnCount, Integer.MAX_VALUE);
                    }
                } catch (IOException e) {
                    session.removeServer(e, i--, ++count);
                }
            }
            session.setAutoCommitFromServer(autoCommit);
            session.autoCommitIfCluster();
            session.readSessionState();
            if (generatedKeys != null) {
                return new ResultWithGeneratedKeys.WithKeys(updateCount, generatedKeys);
            }
            return ResultWithGeneratedKeys.of(updateCount);
        } finally {
            session.unlock();
        }
    }

    @Override
    public BatchResult executeBatchUpdate(ArrayList<Value[]> batchParameters, Object generatedKeysRequest) {
        int generatedKeysMode = GeneratedKeysMode.valueOf(generatedKeysRequest);
        boolean readGeneratedKeys = generatedKeysMode != GeneratedKeysMode.NONE;
        int size = batchParameters.size();
        int objectId = readGeneratedKeys ? session.getNextId() : 0;
        final SessionRemote session = this.session;
        session.lock();
        try {
            long[] updateCounts = new long[size];
            MergedResult generatedKeys = null;
            ArrayList<SQLException> exceptions = new ArrayList<>();
            boolean autoCommit = false;
            for (int i = 0, count = 0; i < transferList.size(); i++) {
                prepareIfRequired();
                Transfer transfer = transferList.get(i);
                MergedResult oldGeneratedKeys = generatedKeys;
                generatedKeys = readGeneratedKeys ? new MergedResult() : null;
                ArrayList<SQLException> oldExceptions = exceptions;
                exceptions = new ArrayList<>();
                try {
                    if (transfer.getVersion() >= Constants.TCP_PROTOCOL_VERSION_21) {
                        session.traceOperation("COMMAND_EXECUTE_BATCH_UPDATE", id);
                        transfer.writeInt(SessionRemote.COMMAND_EXECUTE_BATCH_UPDATE).writeInt(id);
                        transfer.writeInt(size);
                        for (Value[] parameters : batchParameters) {
                            int len = parameters.length;
                            transfer.writeInt(len);
                            sendParameters(transfer, parameters);
                        }
                        sendGeneratedKeysRequest(generatedKeysRequest, generatedKeysMode, transfer);
                        session.done(transfer);
                        for (int j = 0; j < size; j++) {
                            updateCounts[j] = transfer.readRowCount();
                        }
                        if (readGeneratedKeys) {
                            int columnCount = transfer.readInt();
                            ResultRemote remoteGeneratedKeys = new ResultRemote(session, transfer, objectId,
                                    columnCount, Integer.MAX_VALUE);
                            generatedKeys.add(remoteGeneratedKeys);
                            remoteGeneratedKeys.close();
                        }
                        int exceptionCount = transfer.readInt();
                        for (int k = 0; k < exceptionCount; k++) {
                            exceptions.add(SessionRemote.readSQLException(transfer));
                        }
                        autoCommit = transfer.readBoolean();
                    } else {
                        for (int j = 0; j < size; j++) {
                            session.traceOperation("COMMAND_EXECUTE_UPDATE", id);
                            transfer.writeInt(SessionRemote.COMMAND_EXECUTE_UPDATE).writeInt(id);
                            Value[] parameters = batchParameters.get(j);
                            int len = parameters.length;
                            transfer.writeInt(len);
                            sendParameters(transfer, parameters);
                            sendGeneratedKeysRequest(generatedKeysRequest, generatedKeysMode, transfer);
                            try {
                                session.done(transfer);
                                updateCounts[j] = transfer.readRowCount();
                                autoCommit = transfer.readBoolean();
                                if (readGeneratedKeys) {
                                    int columnCount = transfer.readInt();
                                    ResultRemote remoteGeneratedKeys = new ResultRemote(session, transfer, objectId,
                                            columnCount, Integer.MAX_VALUE);
                                    generatedKeys.add(remoteGeneratedKeys);
                                    remoteGeneratedKeys.close();
                                }
                            } catch (DbException e) {
                                updateCounts[j] = Statement.EXECUTE_FAILED;
                                exceptions.add(DbException.toSQLException(e));
                            }
                        }
                    }
                } catch (IOException e) {
                    session.removeServer(e, i--, ++count);
                    generatedKeys = oldGeneratedKeys;
                    exceptions = oldExceptions;
                }
            }
            session.setAutoCommitFromServer(autoCommit);
            session.autoCommitIfCluster();
            session.readSessionState();
            return new BatchResult(updateCounts, generatedKeys != null ? generatedKeys.getResult() : null, exceptions);
        } finally {
            session.unlock();
        }
    }

    private void checkParameters() {
        if (cmdType != EXPLAIN) {
            for (ParameterInterface p : parameters) {
                p.checkSet();
            }
        }
    }

    private void sendParameters(Transfer transfer) throws IOException {
        int len = parameters.size();
        transfer.writeInt(len);
        for (ParameterInterface p : parameters) {
            Value pVal = p.getParamValue();
            if (pVal == null && cmdType == EXPLAIN) {
                pVal = ValueNull.INSTANCE;
            }
            transfer.writeValue(pVal);
        }
    }

    private void sendParameters(Transfer transfer, Value[] parameters) throws IOException {
        for (Value pVal : parameters) {
            if (pVal == null && cmdType == EXPLAIN) {
                pVal = ValueNull.INSTANCE;
            }
            transfer.writeValue(pVal);
        }
    }

    private static void sendGeneratedKeysRequest(Object generatedKeysRequest, int generatedKeysMode, Transfer transfer)
            throws IOException {
        transfer.writeInt(generatedKeysMode);
        switch (generatedKeysMode) {
        case GeneratedKeysMode.COLUMN_NUMBERS: {
            int[] keys = (int[]) generatedKeysRequest;
            transfer.writeInt(keys.length);
            for (int key : keys) {
                transfer.writeInt(key);
            }
            break;
        }
        case GeneratedKeysMode.COLUMN_NAMES: {
            String[] keys = (String[]) generatedKeysRequest;
            transfer.writeInt(keys.length);
            for (String key : keys) {
                transfer.writeString(key);
            }
            break;
        }
        }
    }

    @Override
    public void close() {
        final SessionRemote session = this.session;
        if (session == null || session.isClosed()) {
            return;
        }
        session.lock();
        try {
            session.traceOperation("COMMAND_CLOSE", id);
            for (Transfer transfer : transferList) {
                try {
                    transfer.writeInt(SessionRemote.COMMAND_CLOSE).writeInt(id);
                } catch (IOException e) {
                    trace.error(e, "close");
                }
            }
        } finally {
            session.unlock();
        }
        this.session = null;
        try {
            for (ParameterInterface p : parameters) {
                Value v = p.getParamValue();
                if (v instanceof ValueLob) {
                    ((ValueLob) v).remove();
                }
            }
        } catch (DbException e) {
            trace.error(e, "close");
        }
        parameters.clear();
    }

    /**
     * Cancel this current statement.
     */
    @Override
    public void cancel() {
        session.cancelStatement(id);
    }

    @Override
    public String toString() {
        return sql + Trace.formatParams(getParameters());
    }

    @Override
    public int getCommandType() {
        return cmdType;
    }

}
