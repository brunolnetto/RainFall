import React, { useState, useEffect } from 'react'
import { useWorkflowManager } from '@flowbuild/redux-toolkit-workflow-manager/useWorkflowManager'

import { getWorkflows } from '../../services/workflowService'

import Logo from '../Logo'
import ListItem from '../ListItem'

import * as S from './styles'

const Sidebar = () => {
    const { startWorkflow } = useWorkflowManager()
    const [workflows, setWorkflows] = useState([])

    const handleGetWorkflows = async () => {
        const workflows = await getWorkflows()
        
        setWorkflows(workflows)
    }

    const handleCreateWorkflowByName = async (name, data) => {
        startWorkflow(name, data)
    }

    useEffect(() => {
        handleGetWorkflows()
    }, [])

    return (
        <S.Wrapper>
            <Logo />
            <S.List>
                {workflows?.map((workflow) => (
                    <ListItem item={workflow} key={workflow?.hash} onClick={() => handleCreateWorkflowByName(workflow.name, {})} />
                ))}
            </S.List>
        </S.Wrapper>
    )
}

export default Sidebar