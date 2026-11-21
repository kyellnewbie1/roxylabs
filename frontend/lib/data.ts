export const endpoints=[
 {name:'AI Chat',path:'/api/v1/ai/chat',method:'POST',category:'AI Tools',plan:'Premium',description:'Chat completion endpoint for conversational AI workflows.',handler:'echo',body:{message:'Hello Roxy!',model:'default'}},
 {name:'Text Encoder',path:'/api/v1/text/encode',method:'POST',category:'Utility',plan:'Free',description:'Encode text to Base64 format.',handler:'encode',body:{text:'Roxy Main API'}},
 {name:'QR Generator',path:'/api/v1/tools/qr',method:'POST',category:'Utility',plan:'Free',description:'Generate a QR payload from plain text or a URL.',handler:'qr',body:{text:'https://example.com'}},
 {name:'Image Enhancer',path:'/api/v1/image/enhance',method:'POST',category:'Image Tools',plan:'Premium',description:'Image enhancement endpoint (connect a provider handler to enable processing).',handler:'unavailable',body:{imageUrl:'https://example.com/image.jpg'}}
];
