Feature: Text Scanning Functionality

    Background:
        * configure driver = { type: 'chrome', showDriverLog: true, timeout: 5000 }

    Scenario: Page loads with expected elements
        Given driver 'http://localhost:3000/text_scan.html'
        Then waitFor('h1')
        And match text('h1') == 'Code Scanner'
        And waitFor('#camera-container')
        And waitFor('#camera-feed')
        And waitFor('#scan-button')
        And waitFor('#manual-input-button')
        And waitFor('#manual-input-container')

    Scenario: Manual code input functionality
        Given driver 'http://localhost:3000/text_scan.html'
        Then waitFor('#manual-input-button')
        And delay(12000)

        # Check initial state
        And match script("document.querySelector('#manual-input-container').style.display") == ''
        
        # Click manual input button
        When script("document.querySelector('#manual-input-button').click()")
        Then waitFor('#manual-input-container')
        And match script("document.querySelector('#manual-input-container').style.display") == 'block'
        
        # Enter and submit code
        When script("document.querySelector('#manual-code-input').value = 'TM-II-s-A-06095'")
        And script("document.querySelector('#submit-manual-code').click()")
        
        # Verify code is stored
        Then match script("localStorage.getItem('scannedCode')") == 'TM-II-s-A-06095'

    Scenario: Scan button state management
        Given driver 'http://localhost:3000/text_scan.html'
        Then waitFor('#scan-button')
        
        # Initially disabled
        And match script("document.querySelector('#scan-button').disabled") == true
        
        # Enable after camera and OCR initialization
        And delay(12000)
        And match script("document.querySelector('#scan-button').disabled") == false