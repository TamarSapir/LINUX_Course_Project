FROM openjdk:11

WORKDIR /app

RUN mkdir -p /app/output_java

COPY WatermarkProcessor.java /app/

RUN javac WatermarkProcessor.java

CMD ["java", "WatermarkProcessor", "/app/output_java"]
