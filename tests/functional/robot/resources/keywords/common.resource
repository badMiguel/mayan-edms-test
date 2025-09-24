*** Settings ***
Documentation       Contains keywords for the test

Resource    ../variables.resource

Library     RequestsLibrary
Library     DatabaseLibrary
Library     Collections
Library     String
Library     SeleniumLibrary


*** Keywords ***
Get Headers
    [Documentation]         Get authentitacation token to attach to headers to skip
    ...                     username password login

    Create Session          api    ${BASE_URL}

    ${content_type}=        Create Dictionary   Content-Type=application/json
    ${resp}=                POST On Session
    ...                     api
    ...                     url=/api/v4/auth/token/obtain/?format=json
    ...                     headers=${content_type}
    ...                     data={"username": "${USERNAME}", "password": "${PASSWORD}"}

    ${token}=               Get From Dictionary     ${resp.json()}      token
    ${new_headers}=         Create Dictionary       
    ...                     Content-Type=application/json     Authorization=Token ${token} 

    Set Global Variable     ${HEADERS}      ${new_headers}
    Set Global Variable     ${AUTH_TOKEN}   ${token}

Create Unique String
    [Documentation]     Generate a unique label
    [Arguments]         ${prefix}
    ${time}=            Evaluate    int(time.time())    modules=time
    ${label}=           Catenate    SEPARATOR=_     ${prefix}   ${time}
    RETURN              ${label}

Create String Length
    [Documentation]     Generate a label with character length 1000.
    [Arguments]         ${length}=1000  
    ${long_string}      Generate Random String      ${length}
    RETURN              ${long_string}

Connect To PostgreSQL
    Connect To Database    
    ...     ${DBMODULE}    
    ...     ${DBNAME}    
    ...     ${DBUSER}    
    ...     ${DBPASS}    
    ...     ${DBHOST}    
    ...     ${DBPORT}

Login Via UI
    Open Browser    ${BASE_URL}/authentication/login/       ${BROWSER}
    Input Text      id=id_username     ${USERNAME}
    Input Text      id=id_password     ${PASSWORD}
    Click Button    name=submit
    Wait Until Page Contains    Home    10s
