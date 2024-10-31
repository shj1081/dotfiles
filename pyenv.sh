#!/usr/bin/env bash

# pyenv & virtualenv 설정 스크립트
export PROGNAME="pyenv.sh"
export PY_VERSION="3.9.5"

echo "$PROGNAME: INFO: Starting pyenv setup"

# 1. Python 3.9.5 설치
echo "$PROGNAME: INFO: Installing Python $PY_VERSION with pyenv..."
pyenv install -s "$PY_VERSION"

# 2. 전역 Python 버전을 3.9.5로 설정
echo "$PROGNAME: INFO: Setting global Python version to $PY_VERSION..."
pyenv global "$PY_VERSION"

# 3. 가상 환경 설정 (dm_env, pl_env)
echo "$PROGNAME: INFO: Creating virtual environments dm_env and pl_env..."
pyenv virtualenv "$PY_VERSION" dm_env
pyenv virtualenv "$PY_VERSION" pl_env

# 4. 모든 환경에서 pip 업그레이드
echo "$PROGNAME: INFO: Upgrading pip in global and virtual environments..."

# 전역 pip 업그레이드
~/.pyenv/versions/$PY_VERSION/bin/pip install --upgrade pip

# dm_env 및 pl_env pip 업그레이드
~/.pyenv/versions/$PY_VERSION/envs/dm_env/bin/pip install --upgrade pip
~/.pyenv/versions/$PY_VERSION/envs/pl_env/bin/pip install --upgrade pip

# 5. 패키지 설치
echo "$PROGNAME: INFO: Installing required packages in each environment..."

# 전역 환경에 pyyaml 설치
~/.pyenv/versions/$PY_VERSION/bin/pip install pyyaml

# dm_env 환경에 데이터 분석 패키지 설치
~/.pyenv/versions/$PY_VERSION/envs/dm_env/bin/pip install numpy pandas scikit-learn matplotlib seaborn

echo "$PROGNAME: COMPLETE: pyenv setup with Python $PY_VERSION and virtual environments dm_env, pl_env created."
echo "$PROGNAME: INFO: pip upgraded and required packages installed."

exit
