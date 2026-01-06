import React from "react";
import { BrowserRouter } from "react-router-dom";
import Navigation from '../Navigation'
import Routing from "../../Routing";

export default function MainLayout(){
    return (
        <BrowserRouter>
            <Navigation/>
            <Routing />
        </BrowserRouter>
    )
}