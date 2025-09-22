*** Settings ***
Documentation   Keywords for Cabinet Test Suite
Library         RequestsLibrary
Library         SeleniumLibrary
Library         DatabaseLibrary
Resource        ../variables.resource
Resource        common.resource

*** Keywords ***
Create Cabinet Via API
    [Documentation]     Create a cabinet through POST request on API path 
    ...                 /api/v4/cabinets/. 
    [Arguments]         ${label}    ${parent}=

    ${body}=        Create Dictionary   label=${label}  parent=${parent}
    ${resp}=        POST On Session     api         /api/v4/cabinets/    json=${body}
    ...             headers=${HEADERS}

    ${json}=    Set Variable    ${resp.json()} 
    Log         Created cabinet ${json['id']} - ${json['label']}
    RETURN      ${resp}
