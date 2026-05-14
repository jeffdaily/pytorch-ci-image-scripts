ARG HASH
FROM ghcr.io/pytorch/ci-image:pytorch-linux-noble-rocm-n-py3-${HASH}

# undo the base pytorch CI image sccache wrappers for clang
RUN cd /opt/rocm/llvm/bin && sudo mv original/clang . && sudo mv original/clang++ . && sudo rm -rf original
RUN sudo rm -rf /opt/cache

# install useful utilities
RUN sudo apt update && sudo apt install -y less vim gh && sudo rm -rf /var/lib/apt/lists/*

# install claude
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# fix the image groups/permissions for /dev/dri etc
RUN sudo groupadd -g 109 render
RUN sudo usermod -aG render `whoami`

# my custom vimrc file
ADD .vimrc /var/lib/jenkins/.vimrc

# bootstrap script for claude-shared workflow
ADD bootstrap.sh /var/lib/jenkins/bootstrap.sh
RUN sudo chmod +x /var/lib/jenkins/bootstrap.sh

# disable coredumps, host and GPU
RUN ulimit -c 0

# clone pytorch
RUN cd /var/lib/jenkins && git clone --recursive https://github.com/pytorch/pytorch
# delete last 3 lines that try to run sccache --print-stats since we removed sccache above
RUN cd /var/lib/jenkins/pytorch && head -n -3 .ci/pytorch/build.sh > tmp.sh && chmod +x tmp.sh && mv tmp.sh .ci/pytorch/build.sh
# default pytorch build
RUN cd /var/lib/jenkins/pytorch && MAX_JOBS= .ci/pytorch/build.sh

# git config
RUN git config --global user.name "Jeff Daily" && git config --global user.email "jeff.daily@amd.com"

# install uv
RUN pip install uv

