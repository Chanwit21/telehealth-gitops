#!/bin/bash
# Helper script to deploy telehealth-apps using Helm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
ACTION="install"
NAMESPACE="telehealth-dev"
RELEASE_NAME="telehealth-apps"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -e, --environment ENV    Environment: dev or prod (default: dev)
    -a, --action ACTION      Action: install, upgrade, delete (default: install)
    -n, --namespace NS       Kubernetes namespace (default: telehealth-dev)
    -h, --help              Show this help message

EXAMPLES:
    # Install to development environment
    $0 -e dev

    # Upgrade production environment
    $0 -e prod -a upgrade

    # Delete all releases
    $0 -a delete
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be 'dev' or 'prod'"
    exit 1
fi

# Set namespace based on environment
if [[ "$ENVIRONMENT" == "prod" ]]; then
    NAMESPACE="telehealth-prod"
fi

print_status "Starting Helm $ACTION for $ENVIRONMENT environment in namespace: $NAMESPACE"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_PATH="${SCRIPT_DIR}/../charts/telehealth-apps"
VALUES_FILE="${SCRIPT_DIR}/values-${ENVIRONMENT}.yaml"

# Check if chart exists
if [[ ! -d "$CHART_PATH" ]]; then
    print_error "Chart not found at: $CHART_PATH"
    exit 1
fi

# Check if values file exists
if [[ ! -f "$VALUES_FILE" ]]; then
    print_error "Values file not found at: $VALUES_FILE"
    exit 1
fi

# Validate Helm chart
print_status "Validating Helm chart..."
helm lint "$CHART_PATH"

# Perform action
case $ACTION in
    install)
        print_status "Installing chart..."
        helm install "$RELEASE_NAME" "$CHART_PATH" \
            -n "$NAMESPACE" \
            -f "$VALUES_FILE" \
            --create-namespace
        print_status "✓ Installation complete!"
        ;;
    upgrade)
        print_status "Upgrading chart..."
        helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
            -n "$NAMESPACE" \
            -f "$VALUES_FILE" \
            --create-namespace
        print_status "✓ Upgrade complete!"
        ;;
    delete)
        print_warning "Deleting chart release from $NAMESPACE..."
        read -p "Are you sure? (yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
            print_status "✓ Chart deleted!"
        else
            print_status "Cancelled."
        fi
        ;;
    *)
        print_error "Unknown action: $ACTION"
        exit 1
        ;;
esac

# Show status
print_status "Helm release status:"
helm status "$RELEASE_NAME" -n "$NAMESPACE"

print_status "Kubernetes deployment status:"
kubectl get deployments -n "$NAMESPACE"
