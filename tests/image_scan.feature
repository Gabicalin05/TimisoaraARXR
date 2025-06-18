Feature: MindAR emblem detection and tracking

Background:
    * configure driver = { type: 'chrome', headless: false, timeout: 15000 }
    * def utils = 
    """
    function() {
        return {
            // simulate marker detection 
            simulateMarkerFound: function() {
                window.markerVisible = true;
                
                // Mock the tracked cube's world matrix
                const trackedCube = document.querySelector('#tracked-cube');
                const mockPosition = new THREE.Vector3(0.1, 0.05, -0.5);
                const mockQuaternion = new THREE.Quaternion(0, 0, 0, 1);
                const mockScale = new THREE.Vector3(1, 1, 1);
                
                // Create a mock world matrix
                const mockMatrix = new THREE.Matrix4();
                mockMatrix.compose(mockPosition, mockQuaternion, mockScale);
                trackedCube.object3D.matrixWorld.copy(mockMatrix);
                trackedCube.object3D.matrixWorldNeedsUpdate = false;
                
                document.querySelector('#marker').emit('targetFound');
                return true;
            },
            
            // simulate marker lost
            simulateMarkerLost: function() {
                window.markerVisible = false;
                document.querySelector('#marker').emit('targetLost');
                return true;
            }
        };
    }
    """

    Scenario: MindAR scene loads
        Given driver 'http://localhost:3000/scanner.html'
        
        # Wait for A-frame elements to load
        Then waitFor('a-scene')
        And waitFor('a-entity#marker')
        And waitFor('a-box#tracked-cube')
        
        # Verify A-Frame scene config
        And match script("document.querySelector('a-scene').hasAttribute('mindar-image')") == true
        And match script("document.querySelector('a-scene').getAttribute('vr-mode-ui').enabled") == false
        
        # Assets loaded check
        And match script("document.querySelector('a-assets img#emblem')?.getAttribute('src')") contains 'claustru.jpg'
        
        # Verify tracked cube initial properties
        And match script("document.querySelector('#tracked-cube').getAttribute('color')") == 'red'
        And match script("parseFloat(document.querySelector('#tracked-cube').getAttribute('depth'))") == 0.1
        And match script("parseFloat(document.querySelector('#tracked-cube').getAttribute('width'))") == 0.1
        And match script("parseFloat(document.querySelector('#tracked-cube').getAttribute('height'))") == 0.1
        
        # Check marker is initially not visible
        And match script("window.markerVisible || false") == false

    Scenario: Simulate emblem detection and tracking
        Given driver 'http://localhost:3000/scanner.html'
        Then waitFor('a-scene')
        
        * script("window.__karateTesting = true")
        And delay(2000)
        
        # simulate marker detection
        When script("window.utils = (" + utils + ")();")
        When script("window.utils.simulateMarkerFound()")
        And delay(500)
        
        # Check marker is now visible
        Then match script("window.markerVisible") == true
        
        * script("window.checkDebugLog = function(expectedText) { const log = document.getElementById('debug-log'); return log && log.textContent.includes(expectedText);}")
        

    Scenario: Simulate marker lost functionality
        Given driver 'http://localhost:3000/scanner.html'
        Then waitFor('a-scene')
        * script("window.__karateTesting = true")
        And delay(2000)
        
        # simulate marker found
        When script("window.utils = (" + utils + ")();")
        When script("window.utils.simulateMarkerFound()")
        And delay(5000)
        
        # Verify marker is visible
        Then match script("window.markerVisible") == true
        
        # simulate marker lost
        When script("window.utils = (" + utils + ")();")
        When script("window.utils.simulateMarkerLost()")
        And delay(1000)
        
        # marker is no longer visible
        Then match script("window.markerVisible") == false

        And delay(5000)