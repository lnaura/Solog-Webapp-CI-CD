package com.example.demo.handler;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.example.demo.service.sseService;
import com.fasterxml.jackson.databind.JsonNode; // ❗️ JsonNode를 사용하도록 import 변경
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/aws/sns")
public class snsController {

	private final sseService sseService;
	private final ObjectMapper objectMapper = new ObjectMapper();

	public snsController(sseService sseService) {
		this.sseService = sseService;
	}

	@PostMapping("/message")
	public ResponseEntity<Void> handleSnsMessage(@RequestBody String payload) {
		System.out.println("Received SNS raw payload: " + payload);

		try {
			JsonNode rootNode = objectMapper.readTree(payload.trim());
			String messageType = rootNode.path("Type").asText();

			if ("SubscriptionConfirmation".equals(messageType)) {
				String subscribeUrl = rootNode.get("SubscribeURL").asText();

				new RestTemplate().getForEntity(subscribeUrl, String.class);

			} else if ("Notification".equals(messageType)) {
				String subjectString = rootNode.path("Subject").asText();
				String messageString = rootNode.path("Message").asText();

				sseService.sendLogToClients(subjectString, messageString);
			}
		} catch (Exception e) {
			System.err.println("Error processing SNS message: " + e.getMessage());
			return ResponseEntity.badRequest().build();
		}

		return ResponseEntity.ok().build();
	}
}