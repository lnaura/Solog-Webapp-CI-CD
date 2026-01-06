import React from "react";
import {Route, Routes} from "react-router-dom";
import ProjectMain from "./views/MainPage";
import KibanaPage from "./views/KibanaPage"
import GrafanaPage from "./views/GrafanaPage";
import AiPage from "./views/AiPage";

export default function Routing(){
    return (
        <div>
            <div style={{ marginTop: '64px' }}>
                <Routes>
                    <Route path='/' element={<ProjectMain/>} />
                    <Route path='/kibana' element={<KibanaPage/>} />
                    <Route path='/grafana' element={<GrafanaPage/>} />
                    <Route path='/ai' element={<AiPage/>} />
                </Routes>
            </div>
        </div>
    )
}