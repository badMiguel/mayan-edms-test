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

Create Parent Cabinet Via UI
    [Documentation]     Create a cabinet using the UI
    [Arguments]         ${new_label}

    Go To           ${BASE_URL}/cabinets/cabinets/create/
    Wait Until Element Is Visible    id=id_label    15s
    Input Text      id=id_label     ${new_label}
    Click Button    name=submit

Create Child Cabinet Via UI
    [Documentation]     Create a cabinet using the UI
    [Arguments]         ${new_label}    ${parent_id}   

    Go To           ${BASE_URL}/cabinets/cabinets/${parent_id}/children/add/
    Wait Until Element Is Visible    id=id_label    15s
    Input Text      id=id_label     ${new_label}
    Click Button    name=submit

Get Cabinet By ID
    [Documentation]     Get cabinet using cabinet ID via database query.
    [Arguments]         ${id}
    ${rows}=            Query   
    ...                 SELECT id,label,parent_id FROM cabinets_cabinet WHERE id = ${id}
    RETURN              ${rows}

Cabinet Should Exist In DB By ID
    [Documentation]         Checks that `Get Cabinet By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get Cabinet By ID    ${id}
    Should Not Be Empty     ${rows} Cabinet with id ${id} not found

Wait For Cabinet By ID To Exist In DB
    [Documentation]     Waits until given cabinet exists in the database.
    [Arguments]         ${id}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Cabinet Should Exist In DB By ID   ${id}

Get Cabinet By Label
    [Documentation]     Get cabinet using cabinet ID via database query.
    [Arguments]         ${label}
    ${rows}=            Query   
    ...                 SELECT id,label,parent_id FROM cabinets_cabinet WHERE label = '${label}'
    RETURN              ${rows}

Cabinet Should Exist In DB By Label
    [Documentation]         Checks that `Get Cabinet By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${label}
    ${rows}=                Get Cabinet By Label    ${label}
    Should Not Be Empty     ${rows} Cabinet with label ${label} not found

Wait For Cabinet By Label To Exist In DB
    [Documentation]     Waits until given cabinet exists in the database.
    [Arguments]         ${label}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Cabinet Should Exist In DB By Label   ${label}

Validate Cabinet In DB Via ID
    [Documentation]     Checks that the given label and parent matches the details
    ...                 in the database.
    [Arguments]         ${id}   ${expected_label}   ${expected_parent_id}=${None}

    ${rows}=    Get Cabinet By ID    ${id}
    Should Not Be Empty    ${rows}

    # row = [id, label, parent_id]
    ${row}=     Set Variable    ${rows}[0]
    Should Be Equal    ${row[1]}    ${expected_label}
    IF    '${expected_parent_id}' == '${None}'
        Should Be Equal    ${row[2]}    ${None}
    ELSE
        Should Be Equal As Integers    ${row[2]}    ${expected_parent_id}
    END

Validate Cabinet In DB Via Label
    [Documentation]     Checks that the given label and parent matches the details
    ...                 in the database.
    [Arguments]         ${label}   ${expected_parent_id}=${None}

    ${rows}=    Get Cabinet By Label    ${label}
    Should Not Be Empty    ${rows}

    # row = [id, label, parent_label]
    ${row}=     Set Variable    ${rows}[0]
    Should Not Be Empty    ${row}
    IF    '${expected_parent_id}' == '${None}'
        Should Be Equal    ${row[2]}    ${None}
    ELSE
        Should Be Equal As Integers    ${row[2]}    ${expected_parent_id}
    END
