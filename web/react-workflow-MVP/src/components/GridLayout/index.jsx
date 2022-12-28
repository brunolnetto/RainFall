import React, { useEffect } from 'react'
import { useWorkflowManager } from '@flowbuild/redux-toolkit-workflow-manager/useWorkflowManager';
import AsyncStorage from '@callstack/async-storage';

import * as S from './styles'

export const GridLayout = ({ children }) => {
    const {
        setLogin,
    } = useWorkflowManager()

    const handleLogin = async () => {
        const tokenStorage = await AsyncStorage.getItem('TOKEN');

        if(tokenStorage) {
            const actor_id = await AsyncStorage.getItem('@actor_id');
            const account_id = await AsyncStorage.getItem('@account_id');
            setLogin({ token: tokenStorage, actor_id, account_id });
        }
    }

    useEffect(() => {
        handleLogin()
    }, [])

    return (
        <S.GridLayout>{children}</S.GridLayout>
    )
}

export const Content = ({ children }) => (
    <S.Content>{children}</S.Content>
)
