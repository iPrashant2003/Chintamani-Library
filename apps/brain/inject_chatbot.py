import sys

with open('apps/backend/public/portal/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Patch DOMContentLoaded to call initPortalChatbot
old_init = "      fetchAndRenderPlans();\n    });"
new_init = "      fetchAndRenderPlans();\n      if (typeof initPortalChatbot === 'function') initPortalChatbot();\n    });"
if old_init in content:
    content = content.replace(old_init, new_init)
    print("Patched DOMContentLoaded")
else:
    print("WARNING: DOMContentLoaded pattern not found, trying CRLF variant...")
    old_init2 = "      fetchAndRenderPlans();\r\n    });"
    new_init2 = "      fetchAndRenderPlans();\r\n      if (typeof initPortalChatbot === 'function') initPortalChatbot();\r\n    });"
    if old_init2 in content:
        content = content.replace(old_init2, new_init2)
        print("Patched DOMContentLoaded (CRLF)")
    else:
        print("ERROR: Could not find DOMContentLoaded init block")

CHATBOT = """
  <!-- ================================================================= -->
  <!-- CHINTAMANI AI CHATBOT - External Portal (Public)                   -->
  <!-- ================================================================= -->
  <style>
    #ai-launcher{position:fixed;bottom:22px;right:18px;width:58px;height:58px;border-radius:50%;background:linear-gradient(135deg,#1E1A2C,#12101A);border:1.8px solid rgba(212,175,55,0.85);box-shadow:0 0 18px rgba(212,175,55,0.4),0 5px 14px rgba(0,0,0,0.7);cursor:grab;z-index:9000;display:flex;align-items:center;justify-content:center;opacity:0.52;transition:opacity .25s,transform .2s,box-shadow .2s;user-select:none;-webkit-user-select:none;}
    #ai-launcher:hover{opacity:1;transform:scale(1.06);box-shadow:0 0 28px rgba(212,175,55,0.6),0 8px 20px rgba(0,0,0,0.7);}
    #ai-launcher.dragging{cursor:grabbing;opacity:1;transform:scale(1.08);}
    #ai-launcher img{width:34px;height:34px;object-fit:contain;border-radius:50%;pointer-events:none;}
    #ai-badge{position:absolute;top:-3px;right:-3px;background:#6366F1;color:#fff;font-size:7.5px;font-weight:900;letter-spacing:.5px;padding:2px 4px;border-radius:6px;border:1.5px solid #12101A;pointer-events:none;}
    #ai-panel{position:fixed;bottom:90px;right:14px;width:min(calc(100vw - 28px),400px);height:min(78vh,600px);background:#0F0D18;border-radius:24px;border:1.2px solid rgba(212,175,55,0.35);box-shadow:0 0 40px rgba(0,0,0,0.9),0 0 40px rgba(212,175,55,0.07);display:flex;flex-direction:column;z-index:8999;overflow:hidden;opacity:0;transform:translateY(16px) scale(.96);pointer-events:none;transition:opacity .28s cubic-bezier(.16,1,.3,1),transform .28s cubic-bezier(.16,1,.3,1);}
    #ai-panel.open{opacity:1;transform:translateY(0) scale(1);pointer-events:all;}
    #ai-header{padding:14px 14px 12px;background:linear-gradient(135deg,#1A1730,#16141F);border-bottom:1px solid rgba(212,175,55,0.18);flex-shrink:0;}
    .ai-haccent{height:1.5px;border-radius:2px;margin-bottom:12px;background:linear-gradient(90deg,transparent,rgba(212,175,55,.6),rgba(255,255,255,.8),rgba(212,175,55,.6),transparent);}
    .ai-hrow{display:flex;align-items:center;gap:10px;}
    .ai-lring{width:40px;height:40px;border-radius:50%;padding:7px;flex-shrink:0;background:linear-gradient(135deg,#23203A,#1A1730);border:1.5px solid rgba(212,175,55,.6);box-shadow:0 0 12px rgba(212,175,55,.25);}
    .ai-lring img{width:100%;height:100%;object-fit:contain;border-radius:50%;}
    .ai-title{font-size:15px;font-weight:800;color:#F3E5AB;letter-spacing:.3px;}
    .ai-sub{font-size:10px;color:#6B7280;margin-top:2px;display:flex;align-items:center;gap:4px;}
    .ai-odot{width:6px;height:6px;border-radius:50%;background:#34D399;flex-shrink:0;box-shadow:0 0 6px rgba(52,211,153,.8);}
    .ai-cbtn{margin-left:auto;width:32px;height:32px;border-radius:10px;background:rgba(255,255,255,.06);border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;color:#D4AF37;font-size:18px;transition:background .2s;flex-shrink:0;}
    .ai-cbtn:hover{background:rgba(255,255,255,.12);}
    #ai-messages{flex:1;overflow-y:auto;overflow-x:hidden;padding:14px 12px 8px;background:#0F0D18;scroll-behavior:smooth;}
    #ai-messages::-webkit-scrollbar{width:4px;}
    #ai-messages::-webkit-scrollbar-thumb{background:rgba(212,175,55,.25);border-radius:4px;}
    .ai-mrow{display:flex;align-items:flex-end;gap:7px;margin-bottom:12px;}
    .ai-mrow.u{flex-direction:row-reverse;}
    .ai-av{width:26px;height:26px;border-radius:50%;flex-shrink:0;display:flex;align-items:center;justify-content:center;}
    .ai-av.b{background:#1C1A28;border:1px solid rgba(212,175,55,.4);padding:4px;}
    .ai-av.b img{width:100%;height:100%;object-fit:contain;border-radius:50%;}
    .ai-av.u{background:rgba(212,175,55,.15);border:1px solid rgba(212,175,55,.4);color:#D4AF37;font-size:12px;}
    .ai-bub{max-width:78%;padding:11px 14px;border-radius:18px;font-size:12.5px;line-height:1.55;word-break:break-word;}
    .ai-bub.b{background:linear-gradient(135deg,#1C1A28,#16141F);border:1px solid rgba(255,255,255,.07);border-bottom-left-radius:4px;color:#E2E8F0;}
    .ai-bub.u{background:linear-gradient(135deg,#2A2010,#201808);border:1px solid rgba(212,175,55,.5);border-bottom-right-radius:4px;color:#FDE68A;}
    .ai-sec{color:#E8C97A;font-weight:800;font-size:12.5px;margin:6px 0 3px;}
    .ai-bld{color:#F3E5AB;font-weight:700;}
    .ai-bl{display:flex;gap:6px;margin:2px 0;}
    .ai-bldot{width:5px;height:5px;border-radius:50%;background:#C9A84C;flex-shrink:0;margin-top:6px;}
    .ai-code{display:inline-block;background:#1E1A2E;color:#E8C97A;border:1px solid rgba(201,168,76,.3);border-radius:4px;padding:1px 5px;font-size:11px;font-family:monospace;vertical-align:middle;}
    .ai-typing{display:flex;gap:4px;align-items:center;padding:10px 14px;}
    .ai-dot{width:6px;height:6px;border-radius:50%;background:rgba(212,175,55,.7);animation:aiB .6s ease-in-out infinite alternate;}
    .ai-dot:nth-child(2){animation-delay:.15s;}.ai-dot:nth-child(3){animation-delay:.3s;}
    @keyframes aiB{from{transform:translateY(0);opacity:.6;}to{transform:translateY(-5px);opacity:1;}}
    .ai-ttext{font-size:11px;color:#6B7280;margin-left:6px;}
    #ai-chips{padding:6px 10px;background:#0F0D18;display:flex;gap:6px;overflow-x:auto;flex-shrink:0;scrollbar-width:none;}
    #ai-chips::-webkit-scrollbar{display:none;}
    .ai-chip{flex-shrink:0;display:flex;align-items:center;gap:4px;padding:5px 10px;border-radius:20px;cursor:pointer;background:#1C1A28;border:1px solid rgba(212,175,55,.25);font-size:11px;font-weight:600;color:#F3E5AB;transition:background .2s;white-space:nowrap;}
    .ai-chip:hover{background:rgba(212,175,55,.12);border-color:rgba(212,175,55,.5);}
    #ai-ibar{padding:8px 12px 14px;background:#16141F;border-top:1px solid rgba(212,175,55,.12);display:flex;gap:8px;align-items:flex-end;flex-shrink:0;}
    #ai-input{flex:1;background:#1C1A28;color:#E2E8F0;border:1px solid rgba(255,255,255,.08);border-radius:20px;padding:10px 14px;font-size:13px;resize:none;outline:none;font-family:'Inter',sans-serif;max-height:90px;transition:border-color .2s,box-shadow .2s;}
    #ai-input:focus{border-color:rgba(212,175,55,.55);box-shadow:0 0 0 3px rgba(212,175,55,.1);}
    #ai-input::placeholder{color:rgba(255,255,255,.25);}
    #ai-sbtn{width:44px;height:44px;border-radius:50%;border:none;cursor:pointer;background:linear-gradient(135deg,#E8C97A,#C9A84C,#A07830);box-shadow:0 0 14px rgba(212,175,55,.5);display:flex;align-items:center;justify-content:center;flex-shrink:0;transition:transform .2s;}
    #ai-sbtn:hover{transform:scale(1.05);}
    #ai-sbtn svg{width:18px;height:18px;stroke:#000;}
  </style>

  <div id="ai-launcher" title="Ask ChintaMani AI">
    <img src="images/chintamani_logo.png" onerror="this.src='images/logo.png'" alt="AI">
    <div id="ai-badge">AI</div>
  </div>

  <div id="ai-panel" role="dialog" aria-label="ChintaMani AI" aria-hidden="true">
    <div id="ai-header">
      <div class="ai-haccent"></div>
      <div class="ai-hrow">
        <div class="ai-lring"><img src="images/chintamani_logo.png" onerror="this.src='images/logo.png'" alt="Logo"></div>
        <div>
          <div class="ai-title">ChintaMani AI</div>
          <div class="ai-sub"><span class="ai-odot"></span>Online &bull; Gemini 1.5 Flash &bull; Live</div>
        </div>
        <button class="ai-cbtn" id="ai-xbtn" aria-label="Close">&#x2715;</button>
      </div>
    </div>
    <div id="ai-messages"></div>
    <div id="ai-chips">
      <div class="ai-chip" onclick="aiSend('Available seats today?')">&#x1FA91; Seats</div>
      <div class="ai-chip" onclick="aiSend('Locker status and pricing?')">&#x1F512; Lockers</div>
      <div class="ai-chip" onclick="aiSend('Library timings?')">&#x1F550; Timings</div>
      <div class="ai-chip" onclick="aiSend('How to pay fees via UPI?')">&#x1F4B3; Fee</div>
      <div class="ai-chip" onclick="aiSend('Director contact helpline?')">&#x1F4DE; Contact</div>
    </div>
    <div id="ai-ibar">
      <textarea id="ai-input" rows="1" placeholder="Ask ChintaMani AI anything..."></textarea>
      <button id="ai-sbtn" aria-label="Send">
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/></svg>
      </button>
    </div>
  </div>

  <script>
  (function(){
    var BASE=(function(){var s=window.location.origin; return(s.indexOf('localhost')>=0||s.indexOf('127.0.0.1')>=0||s.indexOf('github.io')>=0)?'https://chintamani-backend.onrender.com':s;})();
    var EP=BASE+'/ai/chat-public', hist=[], typing=false, open=false;
    var launcher=document.getElementById('ai-launcher'), panel=document.getElementById('ai-panel');
    var sx=0,sy=0,sr=18,sb=22,drag=false,dd=0;
    function pos(r,b){launcher.style.right=r+'px';launcher.style.bottom=b+'px';}
    launcher.addEventListener('mousedown',function(e){drag=true;dd=0;sx=e.clientX;sy=e.clientY;sr=parseInt(launcher.style.right)||18;sb=parseInt(launcher.style.bottom)||22;launcher.classList.add('dragging');e.preventDefault();});
    document.addEventListener('mousemove',function(e){if(!drag)return;var dx=e.clientX-sx,dy=e.clientY-sy;dd+=Math.abs(dx)+Math.abs(dy);pos(Math.max(8,Math.min(window.innerWidth-70,sr-dx)),Math.max(8,Math.min(window.innerHeight-70,sb+dy)));});
    document.addEventListener('mouseup',function(){if(drag){launcher.classList.remove('dragging');drag=false;if(dd<8)toggle();}});
    launcher.addEventListener('touchstart',function(e){var t=e.touches[0];drag=true;dd=0;sx=t.clientX;sy=t.clientY;sr=parseInt(launcher.style.right)||18;sb=parseInt(launcher.style.bottom)||22;launcher.classList.add('dragging');},{passive:true});
    document.addEventListener('touchmove',function(e){if(!drag)return;var t=e.touches[0],dx=t.clientX-sx,dy=t.clientY-sy;dd+=Math.abs(dx)+Math.abs(dy);pos(Math.max(8,Math.min(window.innerWidth-70,sr-dx)),Math.max(8,Math.min(window.innerHeight-70,sb+dy)));},{passive:true});
    document.addEventListener('touchend',function(){if(drag){launcher.classList.remove('dragging');drag=false;if(dd<10)toggle();}});

    function toggle(){open=!open;panel.classList.toggle('open',open);panel.setAttribute('aria-hidden',open?'false':'true');if(open){var r=parseInt(launcher.style.right)||18,b=parseInt(launcher.style.bottom)||22;panel.style.right=Math.max(8,r-10)+'px';panel.style.bottom=(b+68)+'px';setTimeout(function(){var i=document.getElementById('ai-input');if(i)i.focus();},300);scrollB();}}
    document.getElementById('ai-xbtn').addEventListener('click',function(){open=false;panel.classList.remove('open');panel.setAttribute('aria-hidden','true');});

    function esc(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
    function fmt(t){return esc(t).replace(/\\*\\*(.+?)\\*\\*/g,'<span class="ai-bld">$1</span>').replace(/`(.+?)`/g,'<span class="ai-code">$1</span>');}
    function render(text){var ls=text.split('\\n'),h='';for(var i=0;i<ls.length;i++){var t=ls[i].trim();if(!t){h+='<div style="height:4px"></div>';continue;}if(/^#{2,3}\\s/.test(t)){h+='<div class="ai-sec">'+esc(t.replace(/^#{2,3}\\s*/,''))+'</div>';continue;}if(/^[\\u2022\\-\\*]\\s/.test(t)){h+='<div class="ai-bl"><div class="ai-bldot"></div><div>'+fmt(t.slice(2))+'</div></div>';continue;}var m=t.match(/^(\\d+)\\.\\s+(.+)$/);if(m){h+='<div class="ai-bl"><div style="color:#C9A84C;font-weight:700;min-width:14px">'+m[1]+'.</div><div>'+fmt(m[2])+'</div></div>';continue;}h+='<div style="margin-bottom:2px">'+fmt(t)+'</div>';}return h;}

    function addMsg(role,text){var msgs=document.getElementById('ai-messages');var row=document.createElement('div');row.className='ai-mrow'+(role==='user'?' u':'');var av=document.createElement('div');av.className='ai-av'+(role==='user'?' u':' b');if(role==='user'){av.textContent='\\uD83D\\uDC64';}else{av.innerHTML='<img src="images/chintamani_logo.png" onerror="this.src=\\'images/logo.png\\'" alt="AI">';}var bub=document.createElement('div');bub.className='ai-bub'+(role==='user'?' u':' b');if(role==='user'){bub.textContent=text;}else{bub.innerHTML=render(text);}if(role==='user'){row.appendChild(bub);row.appendChild(av);}else{row.appendChild(av);row.appendChild(bub);}msgs.appendChild(row);scrollB();}
    function showT(){var msgs=document.getElementById('ai-messages');var row=document.createElement('div');row.className='ai-mrow';row.id='ai-tr';var av=document.createElement('div');av.className='ai-av b';av.innerHTML='<img src="images/chintamani_logo.png" onerror="this.src=\\'images/logo.png\\'" alt="AI">';var bub=document.createElement('div');bub.className='ai-bub b';bub.innerHTML='<div class="ai-typing"><div class="ai-dot"></div><div class="ai-dot"></div><div class="ai-dot"></div><span class="ai-ttext">Thinking...</span></div>';row.appendChild(av);row.appendChild(bub);msgs.appendChild(row);scrollB();}
    function hideT(){var e=document.getElementById('ai-tr');if(e)e.remove();}
    function scrollB(){var m=document.getElementById('ai-messages');if(m)m.scrollTop=m.scrollHeight;}

    window.aiSend=window.aiSendMessage=function(text){
      var q=(text||document.getElementById('ai-input').value||'').trim();
      if(!q||typing)return;
      document.getElementById('ai-input').value='';
      addMsg('user',q);hist.push({role:'user',text:q});typing=true;showT();
      var bid=window.currentViewingBranch==='khalilabad'?'bfc5f47b-5c3a-4801-9200-ebcd701acf5f':'a45d90e2-8154-4a83-b83b-fcfa7db86c44';
      fetch(EP,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message:q,branchId:bid,history:hist.slice(-8)}),signal:AbortSignal.timeout(18000)})
        .then(function(r){return r.json();}).then(function(d){var rep=d.reply||'Sorry, I could not process that. Please try again.';hideT();addMsg('model',rep);hist.push({role:'model',text:rep});})
        .catch(function(){hideT();addMsg('model','**Connection error.**\\n\\nUnable to reach server. For urgent help, call **+91 9415919277**');})
        .finally(function(){typing=false;});
    };

    window.initPortalChatbot=function(){
      var inp=document.getElementById('ai-input');
      inp.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();aiSend();}});
      inp.addEventListener('input',function(){inp.style.height='auto';inp.style.height=Math.min(inp.scrollHeight,90)+'px';});
      document.getElementById('ai-sbtn').addEventListener('click',function(){aiSend();});
      addMsg('model','## Namaste! I am ChintaMani AI\\n\\nYour intelligent library assistant for **Chintamani Library**.\\n\\nI can help you with:\\n- **Seat availability** - check available study seats today\\n- **Locker status** - pricing and current availability\\n- **Library timings** - opening and closing hours\\n- **Fee payment** - UPI and due information\\n- **New admission** - how to register as a member\\n- **Director contact** - helpline numbers\\n\\nWhat would you like to know?');
    };
  })();
  </script>
"""

idx = content.rfind('</body>')
if idx == -1:
    print('ERROR: </body> not found')
    sys.exit(1)

new_content = content[:idx] + CHATBOT + '\n</body>\n</html>\n'

with open('apps/backend/public/portal/index.html', 'w', encoding='utf-8') as f:
    f.write(new_content)

print(f'Chatbot injected successfully. Total chars: {len(new_content)}')
