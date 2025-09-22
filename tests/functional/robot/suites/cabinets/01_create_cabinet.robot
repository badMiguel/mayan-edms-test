*** Settings ***
Documentation   Tests create cabinet functionality

Resource    ../../resources/variables.resource
Resource    ../../resources/keywords/common.resource
Resource    ../../resources/keywords/cabinet.resource
Library    Collections

*** Test Cases ***
Create Parent Cabinet Via API
    [Documentation]     Good Case. Successfully create a new parent cabinet via
    ...                 API (no parent field specified).

    ${new_parent_cabinet_label}=    Create Unique Label     Robot_Cabinet
    Set Global Variable             ${new_parent_cabinet_label}

    ${resp}=                    Create Cabinet Via API  ${new_parent_cabinet_label}  
    ${new_parent_cabinet}=      Set Variable    ${resp.json()}     
    Set Global Variable         ${new_parent_cabinet}

    Should Be Equal As Integers     ${resp.status_code}                 201
    Dictionary Should Contain Key   ${new_parent_cabinet}               id
    Should Be Equal                 ${new_parent_cabinet["label"]}      ${new_parent_cabinet_label}
    Should Be Equal                 ${new_parent_cabinet["parent"]}     ${null}
    
    Wait For Cabinet By ID To Exist In DB    ${new_parent_cabinet["id"]}
    Validate Cabinet In DB    ${new_parent_cabinet["id"]}    ${new_parent_cabinet["label"]}

# Create Duplicate Parent Cabinet Via API
#     [Documentation]     Bad Case. Should NOT be able to create a new parent 
#     ...                 cabinet via API if specified label already exists.
#
#     ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
#     ...         Create Cabinet Via API     ${new_parent_cabinet_label}  
#
#     Should Contain    ${resp}    400

Create Parent Cabinet Without Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new parent 
    ...                 cabinet via API if no label is specified or empty ("")

    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Cabinet Via API    ${EMPTY}

    Should Contain    ${resp}    400


Create Child Cabinet Via API
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

    Wait For Cabinet By ID To Exist In DB    ${new_parent_cabinet["id"]}
    Validate Cabinet In DB    ${new_parent_cabinet["id"]}    ${new_parent_cabinet["label"]}

Create Duplicate Child Cabinet Via API
    [Documentation]     Bad Case. Should NOT be able to create a new child cabinet 
    ...                 via API with specified parent cabinet id if the child cabinet
    ...                 label already exists.

    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Cabinet Via API    ${new_child_cabinet_label}  ${new_parent_cabinet["id"]}

    Should Contain     ${resp}  400

Create Child Cabinet Without Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new child cabinet 
    ...                 via API without specifying label field.

    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Cabinet Via API    ${EMPTY}  ${new_parent_cabinet["id"]}

    Should Contain     ${resp}  400

Create Child Cabinet Without Parent Via API
    [Documentation]     Bad Case. Should NOT be able to create a new child cabinet 
    ...                 via API without specifying parent field. This just creates
    ...                 a new parent cabinet.


    ${new_label}=   Create Unique Label         Robot_Cabinet
    ${resp}=        Create Cabinet Via API      ${new_label}    ${EMPTY}
    ${new_cabinet}  Set Variable                ${resp.json()}

    Should Be Equal As Integers     ${resp.status_code}         201
    Dictionary Should Contain Key   ${new_cabinet}              id
    Should Be Equal                 ${new_cabinet["label"]}     ${new_label}
    Should Be Equal                 ${new_cabinet["parent"]}    ${null}


Create Child Cabinet With Invalid Parent Via API
    [Documentation]     Bad Case. Should NOT be able to create a new child cabinet 
    ...                 via API if parent cabinet does not exist from the specified
    ...                 parent ID.

    ${new_label}=   Create Unique Label         Robot_Cabinet
    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Cabinet Via API          ${new_label}    0 

    Should Contain     ${resp}  400

Create Cabinet With Very Long Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new cabinet via
    ...                 API if label is greater than 128 characters.

    ${new_label}=   Create Very Long Label          129
    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Create Cabinet Via API          ${new_label}    

    Should Contain     ${resp}  400

    ${new_label}=   Create Very Long Label          128
    ${resp}=        Create Cabinet Via API          ${new_label}    

    Should Be Equal As Integers     ${resp.status_code}    201
