"""
Populate the database with data.
"""

import os
import requests
import psycopg2

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


def get_documents():
    r = requests.get(
        url=f"{BASE}/api/v4/documents/",
        headers=headers,
    )
    r.raise_for_status()
    return r.json()["results"]


def get_metadata():
    r = requests.get(
        url=f"{BASE}/api/v4/metadata_types/",
        headers=headers,
    )
    r.raise_for_status()
    return r.json()["results"]


def get_tags():
    r = requests.get(
        url=f"{BASE}/api/v4/tags/",
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


def create_cabinet(idx):
    r = requests.post(
        url=f"{BASE}/api/v4/cabinets/",
        json={"label": f"Seed Cabinet {idx + 1}", "parent": None},
        headers=headers,
    )
    r.raise_for_status()


def create_metadata(idx):
    r = requests.post(
        url=f"{BASE}/api/v4/metadata_types/",
        json={"label": f"Seed Metadata {idx + 1}", "name": f"seed_metadata_{idx + 1}"},
        headers=headers,
    )
    r.raise_for_status()

    # configure created metadata to be optional when creating document
    enable_metadata = requests.post(
        # document id = 1 (default)
        url=f"{BASE}/api/v4/document_types/1/metadata_types/",
        json={"metadata_type_id": r.json()["id"], "required": False},
        headers=headers,
    )
    enable_metadata.raise_for_status()


def create_tags(idx):
    r = requests.post(
        url=f"{BASE}/api/v4/tags/",
        json={"label": f"Seed Tag {idx + 1}", "color": f"#{str(idx + 1)*6}"},
        headers=headers,
    )
    r.raise_for_status()


def create_document(path, idx):
    # create document
    new_document = requests.post(
        url=f"{BASE}/api/v4/documents/",
        json={"document_type_id": 1, "label": f"Seed Document {idx + 1}"},
        headers=headers,
    )
    new_document.raise_for_status()

    # add file to the document
    with open(file=path, mode="rb") as file_object:
        upload_file = requests.post(
            url=f"{BASE}/api/v4/documents/{new_document.json()["id"]}/files/",
            files={"file_new": file_object},
            data={"action_name": "replace"},
            headers={"Authorization": headers["Authorization"]},
        )
        upload_file.raise_for_status()

    # add document to cabinet
    add_to_cabinet = requests.post(
        url=f"{BASE}/api/v4/cabinets/{get_cabinets()[idx]["id"]}/documents/add/",
        json={"document": new_document.json()["id"]},
        headers=headers,
    )
    add_to_cabinet.raise_for_status()

    # add tag to document

    add_tag = requests.post(
        url=f"{BASE}/api/v4/documents/{new_document.json()["id"]}/tags/attach/",
        json={"tag": get_tags()[idx]["id"]},
        headers=headers,
    )
    add_tag.raise_for_status()

    # add metadata do document
    add_metadata = requests.post(
        url=f"{BASE}/api/v4/documents/{new_document.json()["id"]}/metadata/",
        json={
            "metadata_type_id": get_metadata()[idx]["id"],
            "value": f"Metadata Data {idx + 1}",
        },
        headers=headers,
    )
    add_metadata.raise_for_status()


def truncate_table(table_name):
    """
        using direct query to clear table because using request to delete only 
        deletes 10 items
    """
    # no try catch, just stop program when error
    connection = psycopg2.connect(
        host="localhost", database="mayan", user="mayan", password="mayandbpass"
    )

    cursor = connection.cursor()
    cursor.execute(f"TRUNCATE TABLE {table_name} RESTART IDENTITY CASCADE;")
    connection.commit()
    if connection and cursor:
        cursor.close()
        connection.close()


def nuke_database():
    truncate_table("cabinets_cabinet")
    truncate_table("documents_document")
    truncate_table("tags_tag")
    truncate_table("metadata_metadatatype")

if __name__ == "__main__":
    headers["Authorization"] = f"Token {get_api_token()}"

    # delete everything if things gets crazy
    nuke_database()

    if len(get_cabinets()) == 0:
        for i in range(5):
            create_cabinet(i)

    if len(get_metadata()) == 0:
        for i in range(5):
            create_metadata(i)

    if len(get_tags()) == 0:
        for i in range(5):
            create_tags(i)

    if len(get_documents()) == 0:
        file_path = os.path.join(
            DIR, "tests", "functional", "robot", "data", "TestFile.pdf"
        )
        for i in range(5):
            create_document(file_path, i)
