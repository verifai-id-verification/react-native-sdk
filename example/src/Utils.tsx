export function deleteFields(obj: any, fields: string[]): void {
  for (const field of fields) {
    if (field in obj) {
      delete obj[field];
    }
  }

  for (const key in obj) {
    if (typeof obj[key] === 'object' && obj[key] !== null) {
      deleteFields(obj[key], fields);
    }
  }
}
