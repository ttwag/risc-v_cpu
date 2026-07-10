FROM rust:latest

# 1. Install dependencies (rust:latest already has git and curl, but it's good practice to ensure ca-certificates are up to date)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    iverilog \
    && rm -rf /var/lib/apt/lists/*

# 2. Download and extract the xPack RISC-V GCC toolchain
RUN curl -L https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-arm64.tar.gz \
    | tar xz -C /opt

# 3. Clone and build your custom Rust-based compiler
# (No need to load rustup environments here, 'cargo' just works)
RUN git clone https://github.com/ttwag/risc-v_compiler.git /opt/my-compiler && \
    cd /opt/my-compiler && \
    cargo build --release --target-dir .

# 4. Add GCC, custom compiler, and Cargo binaries (Surfer) to the system PATH
ENV PATH="/opt/xpack-riscv-none-elf-gcc-14.2.0-3/bin:/opt/my-compiler/release:${PATH}"