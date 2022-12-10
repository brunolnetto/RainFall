import React, { Component } from 'react';
import Button from 'react-bootstrap/Button';
import { Link } from 'react-router-dom'
import { WorkflowManager }  from '@flowbuild/redux-toolkit-workflow-manager'

import 'bootstrap/dist/css/bootstrap.min.css';
import logo from '../assets/images/flowbuild-logo.png';

const json = require('../samples/blueprints/POC_userTask.json');

class home extends Component {
  render() {
    const { startWorkflow } = useWorkflowManager()
    const [workflows, setWorkflows] = useState([])

    startWorkflow(name, data);

    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to a Flowbuild use case</h1>
          <h>This is a userTask MVP.</h>
          <h>Press the button below to start.</h>
        </header>
        <p className="App-intro">
        <Link to="/control"> 
          <Button
            variant="primary"
            onClick={init_handleFunc}
          >
          Start
          </Button>
        </Link>
        </p>
      </div>
    );
  }
}

async function init_handleFunc(){
  alert('Process started');
}

export default home;
