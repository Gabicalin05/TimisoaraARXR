// Maintain reference to all map markers for search functionality
let markers = {};

// Build search interface elements
const searchContainer = document.createElement('div');
searchContainer.className = 'search-container';

const searchInput = document.createElement('input');
searchInput.type = 'text';
searchInput.placeholder = 'Search monuments...';
searchInput.className = 'search-input';

// Search UI injected into DOM
searchContainer.appendChild(searchInput);
document.getElementById('map').parentNode.appendChild(searchContainer);

// Real-time filtering of map markers
searchInput.addEventListener('input', (e) => {
    // Get search term and normalize to lowercase for case-insensitive matching
    const searchTerm = e.target.value.toLowerCase();
    
    // Iterate through all stored markers
    Object.values(markers).forEach(marker => {
        // Extract popup content (monument name) and normalize case
        const name = marker.getPopup().getContent().toLowerCase();
        
        // Show popup for markers that match search term
        if (name.includes(searchTerm)) {
            marker.openPopup();
        }
    });
});

// Create Leaflet map centered on Timișoara, Romania
var map = L.map('map').setView([45.75, 21.23], 13); // Coordinates: Timișoara city center, zoom level 13

// Add OpenStreetMap tiles as base layer
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// Fetch landmark data from server API
fetch('/api/landmarks')
    .then(response => response.json())
    .then(landmarks => {
        // Process each landmark from database
        landmarks.forEach(landmark => {
            // Create map marker at landmark coordinates
            const marker = L.marker([landmark.latitude, landmark.longitude]).addTo(map);
            
            // Store marker in global collection for search functionality
            // Key: landmark name, Value: marker object
            markers[landmark.name] = marker;
            
            const popupContent = `
                <h3>${landmark.name}</h3>
                <p>${landmark.description}</p>
                
                <!-- 3D Model Viewer: Embedded A-Frame scene for interactive preview -->
                <div id="model-container">
                    <a-scene embedded style="width: 100%; height: 200px;">
                        <!-- Asset Management: Preload textures and 3D models -->
                        <a-assets>
                            <img id="ground" src="assets/cobble.jpg">           <!-- Ground texture -->
                            <img id="ground-NRM" src="assets/cobble-nrm.jpg">  <!-- Normal map for ground -->
                            <img id="sky" src="assets/sky.jpg">                 <!-- Sky texture -->
                            <a-asset-item id="model" src="${landmark.glb_file}"></a-asset-item> <!-- 3D model file -->
                        </a-assets>
                        
                        <!-- Environment Setup -->
                        <a-sky src="#sky"></a-sky> <!-- 360-degree sky backdrop -->
                        
                        <!-- Ground Plane: Textured floor with normal mapping for realistic lighting -->
                        <a-plane 
                            src="#ground" 
                            repeat="10 10" 
                            normal-map="#ground-NRM" 
                            normal-texture-repeat="10 10" 
                            shader="flat" 
                            scale="50 50 1" 
                            rotation="-90 0 0">
                        </a-plane>
                        
                        <!-- Camera Rig: User controls and positioning -->
                        <a-entity id="rig" movement-controls="controls: gamepad,keyboard">
                            <a-entity position="15 0 10"> <!-- Camera positioned for optimal model viewing -->
                                <a-camera 
                                    user-height="1.6" 
                                    look-controls="pointerLockEnabled: true">
                                </a-camera>
                            </a-entity>
                        </a-entity>
                        
                        <!-- 3D Model: Scaled landmark model for preview -->
                        <a-entity scale="0.3 0.3 0.3" gltf-model="#model"></a-entity>
                    </a-scene>
                </div>
                
                <!-- Action Button: Trigger AR scanning workflow -->
                <button 
                    onclick="startScan('${landmark.building_code}')" 
                    style="padding: 12px 24px; 
                           background: #4CAF50; 
                           color: white; 
                           border: none; 
                           border-radius: 4px; 
                           font-size: 16px; 
                           cursor: pointer; 
                           margin: 10px 0; 
                           width: 100%;">
                    Scan Building
                </button>
            `;
            
            // Bind popup content to marker
            marker.bindPopup(popupContent);
        });
    })
    .catch(err => {
        // Log failed API requests
        console.error('Failed to load landmarks:', err);
    });

// Initialize scanning workflow for specific building
function startScan(buildingCode) {
    // Store expected building code for scanner validation
    localStorage.setItem('expectedCode', buildingCode);
    
    // Launch scanning interface in new tab
    window.open('text_scan.html', '_blank');
}