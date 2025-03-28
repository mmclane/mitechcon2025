import streamlit as st
import os
import logging

local = os.getenv("LOCAL", "false").lower()
color = os.getenv("TXT_COLOR", "white").lower()
env = os.getenv("RUN_ENV", "local").upper()

if local == 'true':
    rootdir = "./application"
else:
    rootdir = "/application"

with open(f"{rootdir}/title.txt", "r", encoding="utf-8") as file:
    hello = file.read()
st.title(hello)
logging.info(f"Color: {color}")


if color != "white":
    st.markdown(f'# :{color}[Welcome to {env}!]')
else:
    st.markdown(f'# Welcome to {env}')

alien = st.empty()

alien.image(f"{rootdir}/alien.png")

with open(f"{rootdir}/message.txt", "r", encoding="utf-8") as file:
    message = file.read()
logging.info(f"Message: {message}")


with open(f"{rootdir}/version.txt", "r", encoding="utf-8") as file:
    version = file.read()
logging.info(f"Message: {version}")

if color != "white":
    st.markdown(f':{color}[{message}]')
    st.markdown(f':{color}[{version}]')
else:
    st.markdown(f'{message}')
    st.markdown(f"{version}")
