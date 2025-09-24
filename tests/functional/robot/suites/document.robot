*** Settings ***
Documentation   Tests create document functionality. 

Resource    ../resources/variables.resource
Resource    ../resources/keywords/common.resource
Resource    ../resources/keywords/document.resource
Library     Collections

*** Test Cases ***
####################################################
# Note: Document stub is a document without a file #
####################################################
Create Valid Document Stub Via API
    [Documentation]     Good Case. Successfully create a new document via API.

    ${new_document_label}=      Create Unique String    Document_Label
    Set Global Variable         ${new_document_label}

    ${resp}=                Create Document Stub Via API    1   ${new_document_label}
    ${new_document_stub}=   Set Variable                    ${resp.json()}     

    Set Global Variable     ${new_document_stub}

    ${id}=      Set Variable    ${new_document_stub["id"]}

    Should Be Equal As Integers     ${resp.status_code}                 201
    Dictionary Should Contain Key   ${new_document_stub}                id
    Should Be Equal                 ${new_document_stub["label"]}       ${new_document_label}
    
    Wait For Document Stub By ID To Exist In DB    ${new_document_stub["id"]}
    Validate Document Stub In DB Via ID    ${new_document_stub["id"]}     ${new_document_label}

Upload File To Document Stub Via API
    [Documentation]     Good Case. Successfully uploads file to document stub via API.

    ${resp}=        Add File To Document Stub Via API    ${new_document_stub["id"]}
    ...             replace     ${FILEPATH}

    Should Be Equal As Integers         ${resp.status_code}     202
    Wait For File To Exist In DB        ${FILENAME}             id=${new_document_stub["id"]}
    Validate File Added To Document     ${FILENAME}             id=${new_document_stub["id"]}

Create Document Stub Without Document Type Via API
    [Documentation]     Bad Case. Should NOT be able to create a new document
    ...                 stub via API without document type specified. 

    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Create Document Stub Via API    ${EMPTY}

    Should Contain    ${resp}    400

Create Document Stub With Non-existent Document Type Via API
    [Documentation]     Bad Case. Should NOT be able to create a new document
    ...                 stub via API if specified document type id does not exist

    ${resp}=        Run Keyword And Expect Error    HTTPError: 404 Client Error: Not Found*
    ...             Create Document Stub Via API    0

    Should Contain    ${resp}    404

Upload File To Document Stub Without Action Name And File Via API
    [Documentation]     Bad Case. Should NOT be able to upload a file to document
    ...                 stub via API if no action name and file specified

    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Add File To Document Stub Via API    ${new_document_stub["id"]}     ${EMPTY}    ${EMPTY} 

    Should Contain    ${resp}    400

Upload File To Document Stub Without Action Name Via API
    [Documentation]     Bad Case. Should NOT be able to upload a file to document
    ...                 stub via API if no action name specified

    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Add File To Document Stub Via API    ${new_document_stub["id"]}     ${EMPTY}    ${FILEPATH} 

    Should Contain    ${resp}    400

Upload File To Document Stub Without File Via API
    [Documentation]     Bad Case. Should NOT be able to upload a file to document
    ...                 stub via API if no file specified

    ${resp}=        Run Keyword And Expect Error     HTTPError: 400 Client Error: Bad Request*
    ...             Add No File To Document Stub Via API    ${new_document_stub["id"]}     replace

    Should Contain    ${resp}    400

Upload File With Long Filename
    [Documentation]     Bad Case. Should NOT be able to upload a file to document
    ...                 stub via API if fileaname > 255 characters.

    ${long_filename}=   Create String Length    256
    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Add File To Document Stub Via API    ${new_document_stub["id"]}
    ...         replace    ${FILEPATH}     filename=${long_filename}

    Should Contain    ${resp}    400

    ${short_filename}=  Create String Length    255
    ${resp}=    Add File To Document Stub Via API    ${new_document_stub["id"]}     
    ...         replace    ${FILEPATH}     filename=${short_filename} 

    Should Be Equal As Integers     ${resp.status_code}     202

# Upload File To Document Stub With Invalid Action Name Via API
#     [Documentation]     append, keep, replace
#     No Operation

Add Existing Metadata To Document Via API
    ${rows}=    Get Metadata Type By Label    Seed Metadata 1
    ${metadata_type_id}=    Set Variable    ${rows[0][0]}

    ${resp}=    Add Metadata To Document Via API    ${metadata_type_id}    ${new_document_stub["id"]}
    ${metadata_document}=   Set Variable    ${resp.json()["metadata_type"]}
    
    Should Be Equal As Integers     ${resp.status_code}     201
    Dictionary Should Contain Key   ${metadata_document}    id

    Should Be Equal     ${metadata_document["label"]}       Seed Metadata 1
    
    Wait For Metadata Document To Exist In DB       ${metadata_document["id"]}
    Validate Metadata Added To Document    ${metadata_document["id"]}     ${new_document_stub["id"]}

Add Duplicate Metadata To Document Via API
    No Operation

Add Non-existing Metadata To Document Via API
    No Operation

Add Existing Tag To Document Via API
    No Operation

Create Valid Document Via UI
    No Operation

Create Document Without Label Via UI
    No Operation

Create Duplicate Document Via UI
    No Operation
