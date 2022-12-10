import jwt_decode from "jwt-decode";
import { getWorkflowTokenByActorId } from './workflowService'
import AsyncStorage from '@callstack/async-storage';

import { nanoid } from 'nanoid/async'

/*********************************************************************\
| * Connection setup for Workflow Manager with React
\*********************************************************************/

export async function getMQTTClientID() {
    const clientId = await AsyncStorage.getItem('@MQTT_CLIENT_ID')

    if(!clientId) {
        const id = await nanoid()

        await AsyncStorage.setItem('@MQTT_CLIENT_ID', id)

        return id;
    }

    return clientId;
}

export async function getMQTTConfig() {
    const clientId = await getMQTTClientID();

    return {
        host: process.env.REACT_APP_MQTT_HOST,
        port: parseInt(process.env.REACT_APP_MQTT_PORT),
        clientId: clientId
    }
}

/*********************************************************************\
| * Application access information 
\*********************************************************************/

export const getToken = async () => {
    const storageToken = await AsyncStorage.getItem('TOKEN')

    if(!storageToken) {
        const actorId = await getActorID()
        const token = await getWorkflowTokenByActorId(actorId)        
        await AsyncStorage.setItem('TOKEN', token)

        return token
    }

    return storageToken;
}

export const getActorID = async () => {
    const storedActorId = await AsyncStorage.getItem('@actor_id')

    if(!storedActorId) {
        const actorId = await nanoid();

        await AsyncStorage.setItem('@actor_id', actorId);

        return actorId;
    }

    return storedActorId;
}

export const getSessionID = async () => {
    const session_id = await AsyncStorage.getItem('@session_id')

    if(!session_id) {
        const token = getToken();
        const { session_id } = jwt_decode(token)
        
        await AsyncStorage.setItem('@session_id', session_id)    
        
        return session_id
    }

    return session_id
}

export const getAccountID = async () => {
    let account_id = await AsyncStorage.getItem('@account_id')

    if(!account_id) {
        account_id = await nanoid()

        await AsyncStorage.setItem('@account_id', account_id)
        
        return account_id
    }

    return account_id
}

export const login = async () => {
    const storageToken = await getToken();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      

    const { exp } = jwt_decode(storageToken)
    const expireDate = new Date(exp * 1000).getTime()

    // Refresh token
    if(Date.now() > expireDate) {
        await AsyncStorage.removeItem('TOKEN')
        console.log('Logging out!');
        
        return login();
    }

    return storageToken
}

export const setAccessInfo = async () => {
    await getToken();
    await getActorID();
    await getSessionID();
    await getAccountID();
}

export const getAccessInfo = async () => {
    const token = await getToken();
    const actor_id = await getActorID();
    const session_id = await getSessionID();
    const account_id = await getAccountID();
    
    return {
        actor_id: actor_id,
        session_id: session_id,
        account_id: account_id,
        token: token
    };
}

