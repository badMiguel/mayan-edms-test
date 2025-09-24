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
    ...             replace     ${FILE_PATH}

    Should Be Equal As Integers         ${resp.status_code}     202
    Wait For File To Exist In DB        ${FILENAME}             id=${new_document_stub["id"]}
    Validate File Added To Document     ${FILENAME}             id=${new_document_stub["id"]}
