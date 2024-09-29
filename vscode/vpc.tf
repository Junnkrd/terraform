resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {}
# output "az" {
#   value = data.aws_availability_zones.available.names
# }

resource "aws_subnet" "subnet" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

# resource "aws_subnet" "new-subnet-2" {
#   availability_zone = "us-east-1a"
#   vpc_id            = aws_vpc.new-vpc.id
#   cidr_block        = "10.0.2.0/24"
#   tags = {
#     Name = "${var.prefix}-subnet-2"
#   }
# }

resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "new-rt" {
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-rt"
  }
}


resource "aws_route_table_association" "new-rt-association" {
  count          = 2
  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_route_table.new-rt.id
}
