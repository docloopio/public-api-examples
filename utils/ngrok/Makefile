-include .env

WEBHOOK_PORT ?= 5555

.PHONY: start stop status

start:
	@if [ -z "$(NGROK_AUTHTOKEN)" ]; then echo "Error: NGROK_AUTHTOKEN is not set in .env"; exit 1; fi
	@if [ $$(docker ps -q -f name=^ngrok$$ | wc -l) -gt 0 ]; then \
		echo "ngrok is started already."; \
		$(MAKE) --no-print-directory status; \
	else \
		docker run --rm -d --name ngrok --net=host -e NGROK_AUTHTOKEN=$(NGROK_AUTHTOKEN) ngrok/ngrok http $(WEBHOOK_PORT) > /dev/null; \
		echo "ngrok starting in background..."; \
		sleep 2; \
		$(MAKE) --no-print-directory status; \
	fi

status:
	@TUNNEL_URL=$$(curl -s http://localhost:4040/api/tunnels | grep -o 'https://[^"]*' | head -n 1); \
	if [ -n "$$TUNNEL_URL" ]; then \
		echo "Dashboard URL : http://localhost:4040/"; \
		echo "Webhook URL   : $$TUNNEL_URL"; \
	else \
		echo "ngrok is not running or API not reachable"; \
	fi

stop:
	@docker stop ngrok > /dev/null && echo "ngrok stopped."
