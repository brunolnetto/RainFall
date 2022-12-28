# Preamble

This project was bootstrapped with [Create React App](https://github.com/facebookincubator/create-react-app). You can find the most recent version of this guide [here](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md).

The application requires a local or remote server of a Flowbuild instance. Its repository is on the following URL: https://github.com/flow-build/workflow-api

I recommend you to read these pages before start reading the code abount React Webhooks:

- Portuguese: https://pt-br.reactjs.org/docs/hooks-reference.html
- English: https://react-redux.js.org/api/hooks

# How to start

## Flowbuild server instance

1) Clone the repository available in the repository https://github.com/flow-build/workflow-api;

2) Navigate to its root ```/```;

3) Server up with the configured docker environment on the repository:

a) For Windows users, utilize a Docker IDE (Jetbrains produce good ones: https://www.jetbrains.com/help/idea/docker.html);

b) For Linux, find your distro on the Drawer at the left side of the page directed by the URL https://docs.docker.com/engine/install/ .

4) By default, the server is up if its response in the browser to URL https://localhost:3000 is as below:

```
{
	"message":"Flowbuild API is fine!",
	"version":"2.0.1",
	"engine":"^2.4.0",
	"diagram-builder":"^1.0.1"
}  
```

## React application

1) Clone this repository;
2) Run the command ```yarn install``` to install the necessary packages (it may take some minutes);
3) Run the command ```yarn start``` to start the application;  

# How to track

1) Download a Database Management Tool (for example, DBeaver: https://dbeaver.com/);
2) Create a PostgreSQL data source  instance with the credentials available in the URL https://github.com/flow-build/workflow-api/blob/master/.env.docker;
3) If Docker ran correctly, among others, the main workflow tables ```['activity', 'activity_manager', 'packages', 'process', 'process_state', 'timer', 'workflow']``` will appear with populated initial data within;
4) The current application expects to generate a process on every Click event of workflow on the left sidebar. 

Check yourself!
