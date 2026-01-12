#!/bin/bash

# Configuration
SERVICES=("config-server" "discovery-server" "api-gateway" "movie-service" "customer-service" "payment-service" "notification-service")
PID_FILE=".services.pids"
LOG_DIR="logs"

start_services() {
    echo "🚀 Starting all microservices..."
    mkdir -p $LOG_DIR
    
    # Start sequence with specific delays
    for SERVICE in "${SERVICES[@]}"; do
        echo "📂 Starting $SERVICE..."
        nohup mvn spring-boot:run -pl $SERVICE > "$LOG_DIR/$SERVICE.log" 2>&1 &
        echo $! >> $PID_FILE
        
        # Wait for infrastructure to stabilize
        if [[ "$SERVICE" == "config-server" ]]; then
            echo "⏱️ Waiting for Config Server to initialize..."
            sleep 15
        elif [[ "$SERVICE" == "discovery-server" ]]; then
            echo "⏱️ Waiting for Discovery Server to initialize..."
            sleep 15
        else
            sleep 2
        fi
    done
    echo "✅ All services are starting! Check logs in the '$LOG_DIR' directory."
    echo "📊 Eureka Dashboard: http://localhost:8761"
}

stop_services() {
    if [ ! -f $PID_FILE ]; then
        echo "⚠️ No PID file found. Are services running?"
        # Fallback: kill by process name if necessary
        # pkill -f 'spring-boot:run'
        return
    fi

    echo "🛑 Stopping all microservices..."
    while read pid; do
        if ps -p $pid > /dev/null; then
            echo "Stopping PID $pid..."
            kill -9 $pid 2>/dev/null
        fi
    done < $PID_FILE
    
    rm $PID_FILE
    echo "✅ All services stopped."
    
    # Cleanup any leftover maven processes
    pkill -f 'java.*nozie'
}

status_services() {
    echo "🛰️ Service Status:"
    if [ ! -f $PID_FILE ]; then
        echo "❌ No services recorded as running."
        return
    fi
    
    while read pid; do
        if ps -p $pid > /dev/null; then
            echo "✅ PID $pid is active"
        else
            echo "❌ PID $pid is dead"
        fi
    done < $PID_FILE
}

case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        stop_services
        sleep 2
        start_services
        ;;
    status)
        status_services
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
esac
