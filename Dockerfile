# Multi-stage Dockerfile for arc42 template build
# Build stage: Builds the documentation
FROM eclipse-temurin:11-jdk-jammy as builder

WORKDIR /workspace

# Install additional dependencies for PDF generation and font support
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire project
COPY . .

# Make gradlew executable
RUN chmod +x gradlew

# Create version.properties files for all languages if they don't exist
# This ensures the build doesn't fail on missing version files
RUN for lang in CZ DE EN ES FR IT NL PT RU UKR ZH; do \
    if [ ! -f "$lang/version.properties" ]; then \
      mkdir -p "$lang" && \
      echo "revnumber=9.0" > "$lang/version.properties" && \
      echo "revdate=$(date +'%B %Y')" >> "$lang/version.properties" && \
      echo "revremark=" >> "$lang/version.properties"; \
    fi; \
  done

# Build all languages (HTML and PDF)
RUN ./gradlew asciidoctorAll --info

# Runtime stage: Minimal image with just the built output
FROM eclipse-temurin:11-jre-jammy

WORKDIR /workspace

# Install fonts for viewing/validating PDFs
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-noto-cjk \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Copy built documentation from builder stage
COPY --from=builder /workspace/build ./build

# Copy all language directories with source files and version.properties for validation
COPY --from=builder /workspace/CZ/adoc ./CZ/adoc
COPY --from=builder /workspace/CZ/version.properties ./CZ/version.properties
COPY --from=builder /workspace/DE/adoc ./DE/adoc
COPY --from=builder /workspace/DE/version.properties ./DE/version.properties
COPY --from=builder /workspace/EN/adoc ./EN/adoc
COPY --from=builder /workspace/EN/version.properties ./EN/version.properties
COPY --from=builder /workspace/ES/adoc ./ES/adoc
COPY --from=builder /workspace/ES/version.properties ./ES/version.properties
COPY --from=builder /workspace/FR/adoc ./FR/adoc
COPY --from=builder /workspace/FR/version.properties ./FR/version.properties
COPY --from=builder /workspace/IT/adoc ./IT/adoc
COPY --from=builder /workspace/IT/version.properties ./IT/version.properties
COPY --from=builder /workspace/NL/adoc ./NL/adoc
COPY --from=builder /workspace/NL/version.properties ./NL/version.properties
COPY --from=builder /workspace/PT/adoc ./PT/adoc
COPY --from=builder /workspace/PT/version.properties ./PT/version.properties
COPY --from=builder /workspace/RU/adoc ./RU/adoc
COPY --from=builder /workspace/RU/version.properties ./RU/version.properties
COPY --from=builder /workspace/UKR/adoc ./UKR/adoc
COPY --from=builder /workspace/UKR/version.properties ./UKR/version.properties
COPY --from=builder /workspace/ZH/adoc ./ZH/adoc
COPY --from=builder /workspace/ZH/version.properties ./ZH/version.properties

# Copy gradle files for validation tasks
COPY --from=builder /workspace/gradle ./gradle
COPY --from=builder /workspace/gradlew ./
COPY --from=builder /workspace/build.gradle ./
COPY --from=builder /workspace/gradle.properties ./

# Expose a port for serving documentation (optional)
EXPOSE 8080

# Default command: Show build output directory contents
CMD ["bash", "-c", "echo 'Arc42 documentation built successfully!' && echo 'Output location: /workspace/build' && ls -la build/"]
