import React, { Component } from 'react';
import { Link } from 'react-router-dom'
import Button from 'react-bootstrap/Button';
import 'bootstrap/dist/css/bootstrap.min.css';

import logo from '../assets/images/flowbuild-logo.png';

class Control extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Ações de um processo</h1>
        </header>
        <p className="App-intro">
          <Link to="/">
          <Button
              variant="primary"
              onClick={reset_handleFunc}>
            Reset
            </Button>
          </Link>
          <Link to="/control">
              <Button
                variant="primary"
                onClick={continue_handleFunc}>
              Continue
              </Button>
          </Link>
          <Link to="/">
            <Button
              variant="primary"
              onClick={finish_handleFunc}>
            Finish
            </Button>
          </Link>
        </p>
      </div>
    );
  }
}

function reset_handleFunc(){
  alert('Process reseted.');
}

function continue_handleFunc(){
  alert('Process continued.');
}

function finish_handleFunc(){
  alert('Process finished.');
}

export default Control;
