bool isDomainValid(String? email) {
  return email != null && 
    email.toLowerCase().endsWith('@souunit.com.br');
}