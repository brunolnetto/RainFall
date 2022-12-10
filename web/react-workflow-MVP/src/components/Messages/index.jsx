import React from 'react'
import { useWorkflowManager } from '@flowbuild/redux-toolkit-workflow-manager/useWorkflowManager'

import Typography from '../Typography'

import * as S from './styles'

const Messages = () => {
    const { currentActivity } = useWorkflowManager()

    if(!currentActivity) return <React.Fragment />

    const { props } = currentActivity

    return (
        <S.Wrapper>
            <S.Header>
                <Typography tag="h4" spacing="xxsmall">{props?.action.toUpperCase()}</Typography>
            </S.Header>
            {Object.keys(props?.result).map((key, index) => (
                <S.MessageItem key={index}>
                    <Typography tag="heading">{key}: </Typography>
                    <Typography tag="disclaimer" >{props?.result[key]}</Typography>
                </S.MessageItem>
            ))}
        </S.Wrapper>
    )
}

export default Messages