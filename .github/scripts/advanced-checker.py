#!/usr/bin/env python3
import json
import requests
import subprocess
import sys
import os
from datetime import datetime

def check_image_updates(config_file):
    """Check updates for all images from configuration"""
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    updates_needed = []
    
    for image_config in config['images']:
        for channel, details in image_config['channels'].items():
            base_image = f"{image_config['base_image']}:{details['tag']}"
            
            print(f"Checking {image_config['name']}:{channel}...")
            
            # Check through Docker Registry API or Docker Hub API
            if needs_update(base_image, image_config['name'], channel):
                updates_needed.append({
                    'name': image_config['name'],
                    'channel': channel,
                    'tag': details['tag'],
                    'base_image': image_config['base_image'],
                    'dockerfile': details['dockerfile'],
                    'registry': image_config['registry']
                })
                print(f"  Update needed for {image_config['name']}:{channel}")
            else:
                print(f"  No update needed for {image_config['name']}:{channel}")
    
    return updates_needed

def needs_update(base_image, image_name, channel):
    """Check if update is needed for specific image"""
    try:
        # Try to use docker-image-update-checker if available
        result = subprocess.run([
            'docker', 'run', '--rm',
            'lucacome/docker-image-update-checker:latest',
            '--base-image', base_image,
            '--image', f'ghcr.io/606/{image_name}:{channel}',
            '--output', 'json'
        ], capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            data = json.loads(result.stdout)
            return data.get('needs_updating', False)
        
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, json.JSONDecodeError):
        pass
    
    # Fallback: check through Docker Hub API
    return check_dockerhub_updates(base_image)

def check_dockerhub_updates(image):
    """Check updates through Docker Hub API"""
    try:
        # Parse image into repository and tag
        if ':' in image:
            repo, tag = image.split(':', 1)
        else:
            repo, tag = image, 'latest'
        
        # Docker Hub API endpoint
        url = f"https://hub.docker.com/v2/repositories/{repo}/tags/{tag}/"
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            # Check last update date
            last_updated = datetime.fromisoformat(data['last_updated'].replace('Z', '+00:00'))
            # If image is older than 7 days, consider update needed
            return (datetime.now().astimezone() - last_updated).days > 7
        
    except (requests.RequestException, KeyError, ValueError):
        pass
    
    # If we can't check, consider update needed
    return True

def main():
    """Main function"""
    config_file = '.github/configs/images.json'
    
    if not os.path.exists(config_file):
        print(f"Error: Configuration file {config_file} not found")
        sys.exit(1)
    
    try:
        updates = check_image_updates(config_file)
        
        if updates:
            print(f"\nFound {len(updates)} images that need updates:")
            for update in updates:
                print(f"  - {update['name']}:{update['channel']} (base: {update['base_image']})")
            
            # Output result in JSON format for GitHub Actions
            print(f"\n::set-output name=updates::{json.dumps(updates)}")
            print(f"::set-output name=has_updates::true")
        else:
            print("\nNo updates needed")
            print("::set-output name=has_updates::false")
        
        # Save result to file
        with open('update_results.json', 'w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'updates': updates,
                'has_updates': len(updates) > 0
            }, f, indent=2)
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
