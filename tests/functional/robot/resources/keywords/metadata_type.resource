*** Settings ***
Documentation   Keywords for Cabinet Test Suite
Library         RequestsLibrary
Library         SeleniumLibrary
Library         DatabaseLibrary
Resource        ../variables.resource
Resource        common.resource

*** Keywords ***
Create Metadata Type Via API
    [Documentation]     Create a metadata type through POST request on API path 
    ...                 /api/v4/metadata_types/. 
    [Arguments]         ${label}    ${name}

    ${body}=        Create Dictionary   label=${label}  name=${name}
    ${resp}=        POST On Session     api         /api/v4/metadata_types/    json=${body}
    ...             headers=${HEADERS}

    ${json}=    Set Variable    ${resp.json()} 
    RETURN      ${resp}

