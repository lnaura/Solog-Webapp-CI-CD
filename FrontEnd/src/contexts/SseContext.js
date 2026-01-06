// src/contexts/SseContext.js
import React, { createContext, useState, useEffect } from "react";

export const SseContext = createContext();

export const SseProvider = ({ children }) => {
    const [notifications, setNotifications] = useState([]);
    const [aiCache, setAiCache] = useState({});
    const API_BASE_URL = process.env.REACT_APP_PROD_BASE_URL;

    useEffect(() => {
        const eventSource = new EventSource(`${API_BASE_URL}/api/connect`);

        eventSource.addEventListener("log", (event) => {
            try {
                var newLogObject = JSON.parse(event.data);
                const message_json_parsed = JSON.parse(newLogObject.message)
                
                newLogObject.timestamp = message_json_parsed.timestamp
                if(newLogObject.timestamp==null){
                    newLogObject.timestamp = message_json_parsed['@timestamp_kst']
                }
                if(newLogObject.timestamp==null){
                    newLogObject.timestamp = message_json_parsed['@timestamp']
                }

                newLogObject.timestamp = newLogObject.timestamp.slice(0, 19).replace('T', ' ');


                setNotifications((prev) => {
                    // 중복 방지
                    if (prev.some((n) => n.id === newLogObject.id)) return prev;
                    return [newLogObject, ...prev];
                });
            } catch (error) {
                console.error("SSE 데이터 파싱 실패:", event.data, error);
            }
        });

        eventSource.onerror = (error) => console.error("SSE 에러:", error);

        return () => {
            eventSource.close();
        };
    }, []);

    return (
        <SseContext.Provider value={{ notifications, setNotifications, aiCache, setAiCache }}>
            {children}
        </SseContext.Provider>
    );
};
