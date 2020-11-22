# Main VPC
resource "aws_vpc" "akhil-vpc" {
    cidr_block = join("", [var.VPC_CIDR, "0.0/16"])
    tags = {
        Name = join("", ["akhil-", var.ENVIRONMENT, "-vpc"])
    }
}

# Internet Gateway
resource "aws_internet_gateway" "akhil-igw" {
    vpc_id = aws_vpc.akhil-vpc.id
    tags = {
        Name = join("", ["akhil-", var.ENVIRONMENT, "-igw"])
    }
}

# Public Subnets
resource "aws_subnet" "akhil-public-subnets" {
    vpc_id = aws_vpc.akhil-vpc.id
    count = length(var.AWS_ZONES)
    cidr_block = join("", [var.VPC_CIDR, "${count.index*16}.0/20"])
    availability_zone = "${var.AWS_REGION}${var.AWS_ZONES[count.index]}"
    tags = {
        Name = "akhil-pub-sub${count.index+1}"
    }
}

# Priavte Subnets
resource "aws_subnet" "akhil-private-subnets" {
    vpc_id = aws_vpc.akhil-vpc.id
    count = length(var.AWS_ZONES)
    cidr_block = join("", [var.VPC_CIDR, "${(count.index+3)*16}.0/20"])
    availability_zone = "${var.AWS_REGION}${var.AWS_ZONES[count.index]}"
    tags = {
        Name = "akhil-pvt-sub${count.index+1}"
    }
}

# Backend Subnets
resource "aws_subnet" "akhil-backend-subnets" {
    vpc_id = aws_vpc.akhil-vpc.id
    count = length(var.AWS_ZONES)
    cidr_block = join("", [var.VPC_CIDR, "${(count.index+6)*16}.0/20"])
    availability_zone = "${var.AWS_REGION}${var.AWS_ZONES[count.index]}"
    tags = {
        Name = "akhil-bend-sub${count.index+1}"
    }
}

# Reserved Subnets
resource "aws_subnet" "akhil-reserved-subnets" {
    vpc_id = aws_vpc.akhil-vpc.id
    count = length(var.AWS_ZONES)
    cidr_block = join("", [var.VPC_CIDR, "${(count.index+9)*16}.0/20"])
    availability_zone = "${var.AWS_REGION}${var.AWS_ZONES[count.index]}"
    tags = {
        Name = "akhil-resrv-sub${count.index+1}"
    }
}

# NAT EIPs
resource "aws_eip" "akhil-nat-eips" {
    count = length(var.AWS_ZONES)
    vpc = true
    tags = {
        Name = "akhil-nat-eip${count.index+1}"
    }
}

# NAT Gateways
resource "aws_nat_gateway" "akhil-nat-gw" {
    count = length(var.AWS_ZONES)
    allocation_id = aws_eip.akhil-nat-eips[count.index].id
    subnet_id = aws_subnet.akhil-public-subnets[count.index].id
    tags = {
        Name = "akhil-nat-gw${count.index+1}"
    }
}

# Public Routetable
resource "aws_route_table" "akhil-public-route-table" {
    vpc_id = aws_vpc.akhil-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.akhil-igw.id
    }
    tags = {
        Name = "akhil-${var.ENVIRONMENT}-pub-rt-table"
    }
}

# Private Routetables
resource "aws_route_table" "akhil-private-route-tables" {
    vpc_id = aws_vpc.akhil-vpc.id
    count = length(var.AWS_ZONES)
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.akhil-nat-gw[count.index].id
    }
    tags = {
        Name = "akhil-${var.ENVIRONMENT}-pvt-rt-table${count.index+1}"
    }
}

# Public Routetable Associations
resource "aws_route_table_association" "akhil-public-rt-associations" {
    count = length(var.AWS_ZONES)
    subnet_id = aws_subnet.akhil-public-subnets[count.index].id
    route_table_id = aws_route_table.akhil-public-route-table.id
}

# Private Routetable Associations
resource "aws_route_table_association" "akhil-private-rt-associations" {
    count = length(var.AWS_ZONES)
    subnet_id = aws_subnet.akhil-private-subnets[count.index].id
    route_table_id = aws_route_table.akhil-private-route-tables[count.index].id
}

# Backend Routetable Associations
resource "aws_route_table_association" "akhil-backend-rt-associations" {
    count = length(var.AWS_ZONES)
    subnet_id = aws_subnet.akhil-backend-subnets[count.index].id
    route_table_id = aws_route_table.akhil-private-route-tables[count.index].id
}

# Reserved Routetable Associations
resource "aws_route_table_association" "akhil-reserved-rt-associations" {
    count = length(var.AWS_ZONES)
    subnet_id = aws_subnet.akhil-reserved-subnets[count.index].id
    route_table_id = aws_route_table.akhil-private-route-tables[count.index].id
}