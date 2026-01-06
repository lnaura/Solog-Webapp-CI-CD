// Chatbot.js
import React, { useState, useRef, useEffect } from "react";
import ReactMarkdown from "react-markdown";
import "./index.css";
import "./chatbot.css";

export default function Chatbot() {
  const [userInput, setUserInput] = useState("");
  const [messages, setMessages] = useState([
    { text: "안녕하세요! 무엇을 도와드릴까요?", sender: "ai" },
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const chatContainerRef = useRef(null);
  const API_BASE_URL = process.env.REACT_APP_PROD_BASE_URL;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!userInput.trim() || isLoading) return;

    const userMessage = { text: userInput, sender: "user" };
    setMessages((prev) => [...prev, userMessage]);

    const currentInput = userInput;
    setUserInput("");
    setIsLoading(true);

    try {
      const response = await fetch(`${API_BASE_URL}/api/solog/chatbot`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt: currentInput }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      const aiMessage = { text: data.response, sender: "ai", isMarkdown: true };
      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      console.error("API 호출 오류:", error);
      const errorMessage = {
        text: "답변 생성 중 오류가 발생했습니다.",
        sender: "ai",
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop =
          chatContainerRef.current.scrollHeight;
    }
  }, [messages, isLoading]);

  return (
    <div className="chat-section">
      <div className="chat-window" ref={chatContainerRef}>
        {messages.map((msg, index) => (
          <div
            key={index}
            className={`message ${
              msg.sender === "user" ? "user-message" : "ai-message"
            }`}
          >
            {msg.isMarkdown ? (
              <div className="ai-markdown">
                <ReactMarkdown>{msg.text}</ReactMarkdown>
              </div>
            ) : (
              msg.text
            )}
          </div>
        ))}

        {isLoading && (
          <div className="message ai-message">답변을 생성 중입니다...</div>
        )}
      </div>

      <form onSubmit={handleSubmit} className="form">
        <input
          type="text"
          value={userInput}
          onChange={(e) => setUserInput(e.target.value)}
          placeholder="AI에게 무엇이든 물어보세요..."
          className="input"
          disabled={isLoading}
        />
        <button type="submit" className="button" disabled={isLoading}>
          전송
        </button>
      </form>
    </div>
  );

}
