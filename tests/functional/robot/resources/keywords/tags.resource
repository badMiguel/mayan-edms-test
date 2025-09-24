*** Settings ***
Documentation   Keywords for Cabinet Test Suite
Library         RequestsLibrary
Library         SeleniumLibrary
Library         DatabaseLibrary
Resource        ../variables.resource
Resource        common.resource

*** Keywords ***
Create Tag Via API
    [Documentation]     Create a tag type through POST request on API path 
    ...                 /api/v4/tags/. 
    [Arguments]         ${label}    ${color}

    ${body}=        Create Dictionary   label=${label}  color=${color}
    ${resp}=        POST On Session     api         /api/v4/tags/    json=${body}
    ...             headers=${HEADERS}

    ${json}=    Set Variable    ${resp.json()} 
    RETURN      ${resp}

Create Tag Via UI
    [Documentation]     Create a tag type using the UI
    [Arguments]         ${new_label}    

    Go To   ${BASE_URL}/tags/tags/create/

    Wait Until Element Is Visible   id=id_label     15s
    Wait Until Element Is Visible   name=submit     15s

    Input Text      id=id_label             ${new_label}
    Click Button    name=submit

Get Tag By ID
    [Documentation]     Get tag using tag ID via database query.
    [Arguments]         ${id}
    ${rows}=            Query   
    ...                 SELECT id,label,color FROM tags_tag WHERE id = ${id}
    RETURN              ${rows}

Tag Should Exist In DB By ID
    [Documentation]         Checks that `Get Tag By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get Tag By ID    ${id}
    Should Not Be Empty     ${rows} Tag with id ${id} not found

Wait For Tag By ID To Exist In DB
    [Documentation]     Waits until given tag exists in the database.
    [Arguments]         ${id}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Tag Should Exist In DB By ID   ${id}

Validate Tag In DB Via ID
    [Documentation]     Checks that the given label and color matches the details
    ...                 in the database.
    [Arguments]         ${id}   ${expected_label}   ${expected_color}

    ${rows}=    Get Tag By ID    ${id}
    Should Not Be Empty    ${rows}

    # row = [id, label, color]
    ${row}=     Set Variable    ${rows}[0]
    Should Be Equal    ${row[1]}    ${expected_label}
    Should Be Equal     ${row[2]}    ${expected_color}

Get Tag By Label
    [Documentation]     Get tag type using tag type ID via database query.
    [Arguments]         ${label}
    ${rows}=            Query   
    ...                 SELECT id,label,color FROM tags_tag WHERE label = '${label}'
    RETURN              ${rows}

Tag Should Exist In DB By Label
    [Documentation]         Checks that `Get Tag By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${label}
    ${rows}=                Get Tag By Label    ${label}
    Should Not Be Empty     ${rows} Tag with label ${label} not found

Wait For Tag By Label To Exist In DB
    [Documentation]     Waits until given tag type exists in the database.
    [Arguments]         ${label}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Tag Should Exist In DB By Label   ${label}

Validate Tag In DB Via Label
    [Documentation]     Checks that the given label and color matches the details
    ...                 in the database.
    [Arguments]         ${label}

    ${rows}=    Get Tag By Label    ${label}
    Should Not Be Empty    ${rows}

    # row = [id, label, color]
    ${row}=                 Set Variable    ${rows}[0]
    Should Not Be Empty     ${row}
    Should Contain          ${row[2]}       000000
