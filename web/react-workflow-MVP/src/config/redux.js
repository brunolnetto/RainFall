import { configureStore } from '@reduxjs/toolkit'

import WorkflowManagerSlice from '@flowbuild/redux-toolkit-workflow-manager/workflowManager.slice';
import loginReducer from '@flowbuild/redux-toolkit-workflow-manager/login.slice';

export default configureStore({
    reducer: {
        login: loginReducer,
        workflowManager: WorkflowManagerSlice(process.env.REACT_APP_BASE_URL)
    }
})

