import React, {useState, useEffect, useContext} from "react";
import ReactMarkdown from "react-markdown";
import "./index.css";
import Chatbot from "./chatbot";
import {SseContext} from "../../contexts/SseContext";
import PrettyJsonViewer from './util';

export default function AiChat() {
  const { notifications, aiCache, setAiCache } = useContext(SseContext);
  const [selectedId, setSelectedId] = useState(null);
  const [viewMode, setViewMode] = useState("notifications");
  const [aiResponse, setAiResponse] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const selectedNotification = notifications.find((n) => n.id === selectedId);
  const API_BASE_URL = process.env.REACT_APP_PROD_BASE_URL;

  const handleNotificationClick = async (id) => {
    if (isLoading) return;
    setSelectedId(id);
    setAiResponse(null);

    if (aiCache[id]) {
      setAiResponse(aiCache[id]);
      return;
    }

    const target = notifications.find((n) => n.id === id);
    if (!target) return;

    setIsLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/api/solog`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt: JSON.stringify(target.message) }),
      });

      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

      const data = await response.json();
      setAiResponse(data.response);

      setAiCache((prev) => ({
        ...prev,
        [id]: data.response,
      }));
    } catch (error) {
      setAiResponse("로그 분석 중 오류가 발생했습니다.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleToggleView = () =>
      setViewMode((prev) => (prev === "notifications" ? "chat" : "notifications"));


  return (
      <div className="container">
        {/* 왼쪽 영역: AI 분석 결과 */}
        <div className="main-content">
          <div className="content-section">
            <h2>AI 로그·메트릭 분석 결과</h2>

            {selectedNotification && (
                <>
                  <h3>📜 감지된 로그</h3>
                  <pre className="log-box">
                    <PrettyJsonViewer data={selectedNotification.message} />
                  </pre>
                </>
            )}

            <br />
            {isLoading ? (
              <div className="loading-text">
                <span className="spinner"></span>
                <p>AI의 조언 가져오는 중...</p>
              </div>
            ) : aiResponse ? (
              <div className="ai-markdown">
                <ReactMarkdown>{aiResponse}</ReactMarkdown>
              </div>
            ) : (
              <p>우측 알림 중 하나를 선택하면 AI 분석 결과가 여기에 표시됩니다.</p>
            )}
          </div>
        </div>

        <div className={`sidebar-container ${viewMode === "chat" ? "chat-view-active" : ""}`}>
          <div className="sidebar-sliding-wrapper">
            <div className="notification-sidebar">
              {notifications.length === 0 ? (
                  <p className="no-alert">아직 수신된 알림이 없습니다.</p>
              ) : (
                  notifications.map((item) => (
                      <div
                          key={item.id}
                          className={`notification-item ${item.id === selectedId ? "active" : ""}`}
                          onClick={() => handleNotificationClick(item.id)}
                          style={{
                            cursor:
                                isLoading && item.id !== selectedId
                                    ? "not-allowed"
                                    : "pointer",
                            opacity:
                                isLoading && item.id !== selectedId
                                    ? 0.5
                                    : 1,
                            pointerEvents:
                                isLoading && item.id !== selectedId
                                    ? "none"
                                    : "auto",
                          }}
                      >
                        <div className="notification-title">{item.subject}</div>
                        <div className="notification-time">{item.timestamp}</div>

                      </div>
                  ))
              )}
            </div>

            <div className="ai-chat-container">
              <Chatbot />
            </div>
          </div>

          <div className="sidebar-button" onClick={handleToggleView}>
            <div className="button-arrow-wrapper">
              <span className="button-arrow arrow-left">←</span>
              <span className="button-arrow arrow-right">→</span>
            </div>
          </div>
        </div>
      </div>
  );
}
