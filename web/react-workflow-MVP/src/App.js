import React, { useEffect, useState } from 'react'

import { WorkflowManager }  from '@flowbuild/redux-toolkit-workflow-manager'

import { ThemeProvider } from 'styled-components'
import { login, getMQTTConfig, getSessionID } from './services/loginService'
import GlobalStyles from './assets/styles/globalStyles'
import themeDefault from './assets/styles/themeDefault'

import { Content, GridLayout } from './components/GridLayout'
import Sidebar from './components/Sidebar'
import Messages from './components/Messages'

const App = () => {
  const [mqttConfig, setMqttConfig] = useState(null)
  const [sessionId, setSessionId] = useState(null)

  const handleSetMqttConfig = async () => {
    const mqttConfig = await getMQTTConfig();

    setMqttConfig(mqttConfig)
  }

  const handleSetSessionId = async () => {
    const sessionId = await getSessionID()

    setSessionId(sessionId)
  }

  useEffect(() => {
    login()
    handleSetMqttConfig()
    handleSetSessionId()
  }, [])

  if(!mqttConfig || !sessionId ) return <React.Fragment/>

  return (
    <WorkflowManager mqttConfig={mqttConfig} sessionId={sessionId}>
      <ThemeProvider theme={themeDefault}>
        <GlobalStyles/>
        <GridLayout>
          <Sidebar/>
          <Content>
            <Messages />
          </Content>
        </GridLayout>
      </ThemeProvider>
    </WorkflowManager>
  );
}

export default App;
