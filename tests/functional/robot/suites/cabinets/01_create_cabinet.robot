*** Settings ***
Documentation   Tests create cabinet functionality

Resource    ../../resources/variables.resource
Resource    ../../resources/keywords/common.resource
Resource    ../../resources/keywords/cabinet.resource
Library    Collections

*** Test Cases ***
Create Parent Cabinet Via API Successfully
    [Documentation]     Good Case. Successfully create a new parent cabinet via
    ...                 API (no parent field specified).

    ${new_parent_cabinet_label}=    Create Unique Label     Robot_Cabinet
    Set Global Variable             ${new_parent_cabinet_label}

    ${resp}=                    Create Cabinet Via API  ${new_parent_cabinet_label}  
    ${new_parent_cabinet}=      Set Variable    ${resp.json()}     
    Set Global Variable         ${new_parent_cabinet}

    Should Be Equal As Integers    ${resp.status_code}    201
    Dictionary Should Contain Key   ${new_parent_cabinet}              id
    Should Be Equal                 ${new_parent_cabinet["label"]}     ${new_parent_cabinet_label}

# Create Duplicate Parent Cabinet Via API Should Fail
#     [Documentation]     Bad Case. Should NOT be able to create a new parent 
#     ...                 cabinet via API if specified label already exists.
#
#     ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
#     ...         Create Cabinet Via API     ${new_parent_cabinet_label}  
#
#     Should Contain    ${resp}    400

Create Child Cabinet Via API Successfully
    [Documentation]     Good Case. Successfully create a new child cabinet via API
    ...                 with specified parent cabinet id.

    ${new_child_cabinet_label}=     Create Unique Label         Robot_Cabinet
    Set Global Variable             ${new_child_cabinet_label}

    ${resp}=                Create Cabinet Via API      ${new_child_cabinet_label}      ${new_parent_cabinet["id"]}
    ${new_child_cabinet}=   Set Variable    ${resp.json()}
    Set Global Variable     ${new_child_cabinet}

    Should Be Equal As Integers     ${resp.status_code}    201
    Dictionary Should Contain Key   ${new_child_cabinet}                  id
    Should Be Equal                 ${new_child_cabinet["label"]}         ${new_child_cabinet_label} 
    Should Be Equal                 ${new_child_cabinet["parent_id"]}     ${new_parent_cabinet["id"]}    

Create Duplicate Child Cabinet Via API Should Fail
    [Documentation]     Bad Case. Should NOT be able to create a new child cabinet 
    ...                 via API with specified parent cabinet id if the child cabinet
    ...                 label already exists.

    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Cabinet Via API    ${new_child_cabinet_label}  ${new_parent_cabinet["id"]}

    Should Contain     ${resp}  400
