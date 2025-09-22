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

Get Cabinet By ID
    [Arguments]     ${id}
    ${rows}=        Query   
    ...             SELECT id,label,parent_id FROM cabinets_cabinet WHERE id = ${id}
    RETURN          ${rows}

Cabinet Should Exist In DB
    [Arguments]     ${id}
    ${rows}=    Get Cabinet By ID    ${id}
    Should Not Be Empty    ${rows} Cabinet with id ${id} not found

Wait For Cabinet By ID To Exist In DB
    [Arguments]     ${id}   ${timeout}=10s      ${interval}=1s
    Wait Until Keyword Succeeds    ${timeout}   ${interval}    Cabinet Should Exist In DB   ${id}


Validate Cabinet In DB
    [Arguments]     ${id}   ${expected_label}   ${expected_parent_id}=${None}

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
