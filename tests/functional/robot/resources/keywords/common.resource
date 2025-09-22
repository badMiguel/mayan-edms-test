*** Settings ***
Documentation       Contains keywords for the test

Resource            ../variables.resource
Library             RequestsLibrary


*** Keywords ***
Get Auth Token
    [Documentation]         Get authentitacation token to attach to headers to skip
    ...                     username password login

    Create Session          api    ${BASE_URL}

    ${resp}=                POST On Session
    ...                     api
    ...                     /api/v4/auth/token/obtain/\?format\=json
    ...                     data={"username": "admin", "password": "jQ4AfQX2Ga"}

    ${token}=               Get    From    Dictionary    ${resp.json()}    token
    Set Global Variable     ${AUTH_TOKEN}    ${token}

Create Unique Label
    [Documentation]     Generate a unique label
    [Arguments]         ${prefix}
    ${time}=            Evaluate    int(time.time()) modules=time
    ${label}=           Catenate    SEPARATOR=_     ${prefix}   ${time}
    [Return]            ${label}

