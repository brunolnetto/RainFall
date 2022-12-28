import axios from 'axios'
import api from '../config/axios'

import sleep from '../utils/time'

const HOST = process.env.REACT_APP_BASE_URL;

export const getWorkflowToken = async () => {
    try {
        const response =  await axios.post(`${HOST}/token`, {});

        return response.data.jwtToken || response.data.token
    } catch(e) {
        throw new Error(`getWorkflowToken: ${e.message}`)
    }
}

export const getWorkflowTokenByActorId = async (actorId) => {
    try {
        const response = await axios.post(`${HOST}/token`, { actor_id: actorId });

        return response.data.jwtToken || response.data.token
    } catch(e) {
        throw new Error(`getWorkflowTokenByActorId: ${e.message}`)
    }
}

export const getWorkflows = async () => {
    try {
        const response = await api.get(`${HOST}/workflows`)

        return response.data
    } catch(e) {
        throw new Error(`getWorkflows: ${e.message}`)
    }
}

export const createWorkflowByName = async (w_name, data = {}) => {
    try {
        const response = await api.post(`${HOST}/workflows/name/${w_name}/start`, data);
        
        return response.data
    } catch(e) {
        throw new Error(`createWorkflowByName: ${e.message}`)
    }
}

export const getCurrentState = async (pid) => {
    try {   
        return await api.post(`${HOST}/processes/${pid}/state`)
    } catch(e) {
        throw new Error(`getCurrentState: ${e.message}`)
    }
}

export const getCurrentActivity = async (pid) => {
    try {
        const _currentState = await getCurrentState(pid);
        
        if(_currentState.current_status === "waiting") {
            return await getCurrentActivity(pid);
        } else{
            return {
                message: `Failed at Activity status must be "waiting". It is currently ${_currentState.currentStatus}}`,
                error: {}
            };
        }
    } catch(e) {
        throw new Error(`getCurrentActivity: ${e.message}`)
    }
}

export const waitProcessStop = async (pid) => {
    const expectedStatus = ["waiting", "error", "finished"];
    let _currentState;
    
    try {
        do {
            _currentState = await getCurrentState(pid);
            await sleep(1000);
        } while (!expectedStatus.includes(_currentState.currentStatus));
     } catch(e) {
        throw new Error(`waitProcessStop: ${e.message}`)
    }

    return;
}

export const waitStopAndGetActivity = async (pid) => {
    await waitProcessStop(pid);
    return getCurrentActivity(pid);
}