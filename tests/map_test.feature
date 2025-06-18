Feature: Interactive Map and Markers

    Background:
        * configure driver = { type: 'chrome', showDriverLog: true, timeout: 5000 }

    Scenario: Map and content loads
        Given driver 'http://localhost:3000/index.html'
        Then waitFor('#map')
        And match text('#map') contains 'Leaflet'

        And delay(5000)

    Scenario: 3D object is rendered inside the landmark popup
        Given driver 'http://localhost:3000/index.html'
        And waitFor('#map')
        And retry(3, 1000).waitFor('.leaflet-marker-icon')
        When script("document.querySelector('.leaflet-marker-icon').click()")
        Then waitFor('.leaflet-popup-content a-scene')
        And match script("document.querySelector('a-entity[gltf-model]')?.getAttribute('gltf-model')") == "#model"
        And match script("document.querySelector('a-plane')?.getAttribute('src')") == "#ground"
        And match script("document.querySelector('a-sky')?.getAttribute('src')") == "#sky"

    Scenario: Interactive markers and scanner link
        Given driver 'http://localhost:3000/index.html'
        And waitFor('#map')
        And retry(3, 1000).waitFor('.leaflet-marker-icon')

        # Clicking first marker
        When script("document.querySelector('.leaflet-marker-icon').click()")

        # Verifying popup content
        Then waitFor('.leaflet-popup-content')
        And def popup = script(".leaflet-popup-content", "_.innerText")
        And match popup contains 'Three Holy Hierarchs Metropolitan Cathedral'
        And match popup contains 'Scan Building'
        And match script(".leaflet-popup-content", "_.innerHTML") contains 'a-scene'

        And delay(5000)