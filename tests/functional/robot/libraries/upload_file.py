import requests
from robot.api.logger import info


def upload_file(base_url, id, path, filename, action_name, headers):
    # add file to the document
    info(
        msg=f"Recieved:\nBase URL:{base_url}\nID:{id}\nPath:{path}\nFilename:{filename}\nAction Name:{action_name}\nHeaders:{headers}\n\n",
        html=True
    )
    if not path:
        resp = requests.post(
            url=f"{base_url}/api/v4/documents/{id}/files/",
            data={"action_name": action_name, "filename": filename},
            headers=headers,
        )
        resp.raise_for_status()

    with open(file=path, mode="rb") as file_object:
        resp = requests.post(
            url=f"{base_url}/api/v4/documents/{id}/files/",
            files={"file_new": file_object},
            data={"action_name": action_name, "filename": filename},
            headers=headers,
        )
        resp.raise_for_status()        

    return resp
