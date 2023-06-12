FROM nvidia/cuda:11.4.3-devel-ubuntu20.04

RUN apt update
RUN apt install -y curl gcc libgmp-dev make libffi-dev libncurses5-dev perl llvm-9 libstdc++-9-dev build-essential
RUN DEBIAN_FRONTEND=noninteractive apt install -y pkg-config

RUN useradd user

USER user
WORKDIR /home/user
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Add ghcup to PATH
ENV PATH=$PATH:/home/user/.local/bin
ENV PATH=$PATH:/home/user/.ghcup/bin

RUN ghcup install ghc 8.10.7
RUN ghcup set ghc 8.10.7
RUN ghcup install cabal

# mark llvm 9 as active
ENV PATH=$PATH:/usr/bin/llvm-9 

RUN cabal install accelerate
RUN cabal install llvm-hs -fshared-llvm --constraint="llvm-hs==9.0.*"
RUN cabal install accelerate-llvm-native

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/compat:/usr/local/cuda/nvvm/lib64
RUN cabal install accelerate-llvm-ptx --constraint="cuda==0.11.*" # attempt gpu support