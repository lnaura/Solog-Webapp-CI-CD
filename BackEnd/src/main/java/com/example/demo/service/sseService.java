package com.example.demo.service;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.google.gson.Gson;

@Service
public class sseService {

	private final AtomicLong eventIdCounter = new AtomicLong(1);
	private final List<SseEmitter> emitters = new CopyOnWriteArrayList<>();

	public SseEmitter createEmitter() {
		SseEmitter emitter = new SseEmitter(600_000L);

		this.emitters.add(emitter);
		System.out.println("New client connected. Total clients: " + emitters.size());

		emitter.onCompletion(() -> {
			this.emitters.remove(emitter);
			System.out.println("Client disconnected. Total clients: " + emitters.size());
		});
		emitter.onTimeout(() -> {
			emitter.complete();
		});

		try {
			emitter.send(SseEmitter.event().name("connect").data("Connection established"));
		} catch (IOException e) {
			System.err.println("Error sending initial connection event: " + e.getMessage());
		}

		return emitter;
	}

	public void sendLogToClients(String subjectString, String messageString) {
		// 현재 연결된 모든 클라이언트에게 로그 데이터를 전송합니다.
		long newId = eventIdCounter.incrementAndGet();
		for (SseEmitter emitter : this.emitters) {
			try {
				Gson gson = new Gson();
				Map<String, Object> jsonMap = new HashMap<>();
				jsonMap.put("id", newId);
				jsonMap.put("subject", subjectString);
				jsonMap.put("message", messageString);

				String jsonResult = gson.toJson(jsonMap);

				emitter.send(SseEmitter.event().name("log").data(jsonResult));
			} catch (IOException e) {
				// 클라이언트와의 연결이 끊겼을 경우의 예외 처리
				System.err.println("Error sending log to client: " + e.getMessage());
			}
		}
	}
}