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

Create Metadata Type Via UI
    [Documentation]     Create a metadata type using the UI
    [Arguments]         ${new_label}    ${new_name}   

    Go To   ${BASE_URL}/metadata/metadata_types/create/

    Wait Until Element Is Visible   id=id_name      15s
    Wait Until Element Is Visible   id=id_label     15s
    Scroll Element Into View        name=submit 
    Wait Until Element Is Visible   name=submit     15s

    Input Text      id=id_name              ${new_name}
    Input Text      id=id_label             ${new_label}
    Click Button    name=submit

Get Metadata Type By ID
    [Documentation]     Get metadata type using metadata type ID via database query.
    [Arguments]         ${id}
    ${rows}=            Query   
    ...                 SELECT id,label,name FROM metadata_metadatatype WHERE id = ${id}
    RETURN              ${rows}

Metadata Type Should Exist In DB By ID
    [Documentation]         Checks that `Get Metadata Type By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get Metadata Type By ID    ${id}
    Should Not Be Empty     ${rows}

Wait For Metadata Type By ID To Exist In DB
    [Documentation]     Waits until given metadata type exists in the database.
    [Arguments]         ${id}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Metadata Type Should Exist In DB By ID   ${id}

Validate Metadata Type In DB Via ID
    [Documentation]     Checks that the given label and name matches the details
    ...                 in the database.
    [Arguments]         ${id}   ${expected_label}   ${expected_name}

    ${rows}=    Get Metadata Type By ID    ${id}
    Should Not Be Empty    ${rows}

    # row = [id, label, name]
    ${row}=     Set Variable    ${rows}[0]
    Should Be Equal    ${row[1]}    ${expected_label}
    Should Be Equal     ${row[2]}    ${expected_name}

Get Metadata Type By Label
    [Documentation]     Get metadata type using metadata type ID via database query.
    [Arguments]         ${label}
    ${rows}=            Query   
    ...                 SELECT id,label,name FROM metadata_metadatatype WHERE label = '${label}'
    RETURN              ${rows}

Metadata Type Should Exist In DB By Label
    [Documentation]         Checks that `Get Metadata Type By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${label}
    ${rows}=                Get Metadata Type By Label    ${label}
    Should Not Be Empty     ${rows}

Wait For Metadata Type By Label To Exist In DB
    [Documentation]     Waits until given metadata type exists in the database.
    [Arguments]         ${label}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Metadata Type Should Exist In DB By Label   ${label}

Validate Metadata Type In DB Via Label
    [Documentation]     Checks that the given label and name matches the details
    ...                 in the database.
    [Arguments]         ${label}   ${expected_name}

    ${rows}=    Get Metadata Type By Label    ${label}
    Should Not Be Empty    ${rows}

    # row = [id, label, name]
    ${row}=     Set Variable    ${rows}[0]
    Should Not Be Empty    ${row}
    Should Be Equal     ${row[2]}    ${expected_name}


