"""
Populate the database with data.
"""

import os
import requests

BASE = "http://localhost:8081"
USERNAME = "admin"
PASSWORD = "jQ4AfQX2Ga"
DIR = os.getcwd()
headers = {"Content-Type": "application/json"}


def get_api_token():
    r = requests.post(
        url=f"{BASE}/api/v4/auth/token/obtain/?format=json",
        data={"username": USERNAME, "password": PASSWORD},
    )
    r.raise_for_status()
    return r.json()["token"]


def create_cabinet(name):
    r = requests.post(
        url=f"{BASE}/api/v4/cabinets/",
        json={"label": name, "parent": None},
        headers=headers,
    )
    r.raise_for_status()


def create_document(path, label):
    r = requests.post(
        url=f"{BASE}/api/v4/documents/",
        json={"document_type_id": 1, "label": label},
        headers=headers,
    )
    r.raise_for_status()

    with open(file=path, mode="rb") as file_object:
        upload_file = requests.post(
            url=f"{BASE}/api/v4/documents/{r.json()["id"]}/files/",
            files={"file_new": file_object},
            data={"action_name": "replace"},
            headers={"Authorization": headers["Authorization"]},
        )

        upload_file.raise_for_status()


def get_documents():
    r = requests.get(
        url=f"{BASE}/api/v4/documents/",
        headers=headers,
    )
    r.raise_for_status()
    return r.json()["results"]


def get_cabinets():
    r = requests.get(
        url=f"{BASE}/api/v4/cabinets/",
        headers=headers,
    )
    r.raise_for_status()
    return r.json()["results"]


def nuke_database():
    # delete all documents

    for i in get_documents():
        r = requests.delete(
            url=f"{BASE}/api/v4/documents/{i["id"]}",
            headers=headers,
        )
        r.raise_for_status()

    # delete all cabinets
    for i in get_cabinets():
        r = requests.delete(
            url=f"{BASE}/api/v4/cabinets/{i["id"]}",
            headers=headers,
        )
        r.raise_for_status()


if __name__ == "__main__":
    headers["Authorization"] = f"Token {get_api_token()}"

    # delete everything if things gets crazy
    nuke_database()

    if len(get_cabinets()) == 0:
        for i in range(5):
            create_cabinet(f"Seed Cabinet {i + 1}")

    if len(get_documents()) == 0:
        for i in range(5):
            create_document(f"{DIR}/tests/data/TestFile.pdf", f"Seed Document {i + 1}")
